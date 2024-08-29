import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
import * as ecr from "aws-cdk-lib/aws-ecr-assets";
import { assertAndReturn } from "./assert-and-return";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";
import { CaveLogDatabaseStack } from "./cavelog-db-stack";

type AppStackProps = {
  vpcStack: CaveLogVpcStack;
  databaseStack: CaveLogDatabaseStack;
};

export type AppEnvProps = { railsMasterKey: string };

export const getCaveLogAppStackPropsFromEnvrionment = (): AppEnvProps => ({
  railsMasterKey: assertAndReturn(
    process.env.RAILS_MASTER_KEY,
    "RAILS_MASTER_KEY",
  ),
});

export class CaveLogAppStack extends cdk.Stack {
  public readonly cluster: ecs.Cluster;
  public readonly service: ecs_patterns.ApplicationLoadBalancedFargateService;
  public readonly task: ecs.FargateTaskDefinition;
  public readonly securityGroup: ec2.SecurityGroup;

  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & AppEnvProps & AppStackProps,
  ) {
    super(scope, id, props);

    this.securityGroup = new ec2.SecurityGroup(this, "FargateSecurityGroup", {
      vpc: props.vpcStack.vpc,
      description: "Allow Fargate tasks to communicate with RDS",
      allowAllOutbound: true,
    });

    this.cluster = new ecs.Cluster(this, "RailsCluster", {
      vpc: props.vpcStack.vpc,
    });

    this.task = new ecs.FargateTaskDefinition(this, "AppTaskDef");
    this.task.addContainer("RailsAppContainer", {
      image: ecs.ContainerImage.fromAsset("../", {
        file: "Dockerfile",
        platform: ecr.Platform.LINUX_AMD64,
      }),
      logging: new ecs.AwsLogDriver({ streamPrefix: "rails-app" }),
      secrets: {
        DB_USERNAME: ecs.Secret.fromSecretsManager(
          props.databaseStack.secret,
          "username",
        ),
        DB_PASSWORD: ecs.Secret.fromSecretsManager(
          props.databaseStack.secret,
          "password",
        ),
      },
      environment: {
        DB_DATABASE: "postgres",
        DB_TIMEOUT: "5000",
        DB_PORT: "5432",
        DB_HOST: props.databaseStack.database.dbInstanceEndpointAddress,
        RAILS_ENV: "production",
        RAILS_SERVE_STATIC_FILES: "true",
        RAILS_LOG_TO_STDOUT: "true",
        RAILS_MASTER_KEY: props.railsMasterKey,
      },
      portMappings: [{ containerPort: 3000 }],
    });

    this.securityGroup.connections.allowTo(
      props.databaseStack.securityGroup,
      ec2.Port.tcp(5432),
      "Allow outbound RDS access",
    );

    props.databaseStack.secret.grantRead(this.task.taskRole);

    this.service = new ecs_patterns.ApplicationLoadBalancedFargateService(
      this,
      "RailsAppService",
      {
        cluster: this.cluster,
        taskDefinition: this.task,
        desiredCount: 1,
        publicLoadBalancer: true,
        listenerPort: 80,
        securityGroups: [this.securityGroup],
        enableExecuteCommand: true,
      },
    );
  }
}
