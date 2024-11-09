import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecr_assets from "aws-cdk-lib/aws-ecr-assets";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
import { assertAndReturn } from "./assert-and-return";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";
import { CaveLogDatabaseStack } from "./cavelog-db-stack";
import { CaveLogDomainStack } from "./cavelog-domain-stack";

type AppStackProps = {
  vpcStack: CaveLogVpcStack;
  databaseStack: CaveLogDatabaseStack;
  domainStack: CaveLogDomainStack
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

    this.task = new ecs.FargateTaskDefinition(this, "RailsAppTaskDef");
    this.task.addContainer("RailsAppContainer", {
      image: ecs.ContainerImage.fromAsset("../", {
        file: "Dockerfile",
        platform: ecr_assets.Platform.LINUX_AMD64,
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
        DB_DATABASE: props.databaseStack.databaseName,
        DB_TIMEOUT: "5000",
        DB_PORT: props.databaseStack.database.clusterEndpoint.port.toString(),
        DB_HOST: props.databaseStack.database.clusterEndpoint.hostname,
        RAILS_ENV: "production",
        RAILS_SERVE_STATIC_FILES: "true",
        RAILS_LOG_TO_STDOUT: "true",
        RAILS_MASTER_KEY: props.railsMasterKey,
      },
      portMappings: [{ containerPort: 3000 }],
    });

    this.securityGroup.connections.allowTo(
      props.databaseStack.securityGroup,
      ec2.Port.tcp(props.databaseStack.database.clusterEndpoint.port),
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
        securityGroups: [this.securityGroup],
        enableExecuteCommand: true,
        publicLoadBalancer: true,
        domainName: props.domainStack.applicationDomainName,
        domainZone: props.domainStack.hostedZone,
        certificate: props.domainStack.certificate,
        listenerPort: 443,
      },
    );
  }
}
