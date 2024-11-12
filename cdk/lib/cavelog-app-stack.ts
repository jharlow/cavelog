import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecr_assets from "aws-cdk-lib/aws-ecr-assets";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
import * as iam from "aws-cdk-lib/aws-iam";
import { assertAndReturn } from "./assert-and-return";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";
import { CaveLogDatabaseStack } from "./cavelog-db-stack";
import { CaveLogDomainStack } from "./cavelog-domain-stack";
import { ok } from "assert";

type AppStackProps = {
  vpcStack: CaveLogVpcStack;
  databaseStack: CaveLogDatabaseStack;
  domainStack: CaveLogDomainStack;
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
  public readonly fargateAlb: ecs_patterns.ApplicationLoadBalancedFargateService;
  public readonly securityGroup: ec2.SecurityGroup;

  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & AppEnvProps & AppStackProps,
  ) {
    super(scope, id, props);
    ok(props.env?.region);

    this.securityGroup = new ec2.SecurityGroup(this, "FargateSecurityGroup", {
      vpc: props.vpcStack.vpc,
      description: "Allow Fargate tasks to communicate with RDS",
      allowAllOutbound: true, // TODO: needed?
    });

    this.securityGroup.connections.allowTo(
      props.databaseStack.securityGroup,
      ec2.Port.tcp(props.databaseStack.database.clusterEndpoint.port),
      "Allow outbound RDS access",
    );

    this.cluster = new ecs.Cluster(this, "RailsCluster", {
      vpc: props.vpcStack.vpc,
    });

    this.fargateAlb = new ecs_patterns.ApplicationLoadBalancedFargateService(
      this,
      "RailsAppService",
      {
        cluster: this.cluster,
        desiredCount: 1,
        securityGroups: [this.securityGroup],
        enableExecuteCommand: true,
        publicLoadBalancer: true,
        domainName: props.domainStack.applicationDomainName,
        domainZone: props.domainStack.hostedZone,
        certificate: props.domainStack.certificate,
        listenerPort: 443,
        assignPublicIp: true,
        taskImageOptions: {
          containerName: "RailsAppContainer",
          image: ecs.ContainerImage.fromAsset("../", {
            file: "Dockerfile",
            platform: ecr_assets.Platform.LINUX_AMD64,
          }),
          containerPort: 3000,
          environment: {
            DB_DATABASE: props.databaseStack.databaseName,
            DB_TIMEOUT: "5000",
            DB_PORT:
              props.databaseStack.database.clusterEndpoint.port.toString(),
            DB_HOST: props.databaseStack.database.clusterEndpoint.hostname,
            RAILS_ENV: "production",
            RAILS_SERVE_STATIC_FILES: "true",
            RAILS_LOG_TO_STDOUT: "true",
            RAILS_MASTER_KEY: props.railsMasterKey,
            APPLICATION_DOMAIN: props.domainStack.applicationDomainName,
            MAILING_DOMAIN: props.domainStack.mailDomainName,
            SES_REGION: props.env.region,
            SES_EMAIL_ADDRESS: `no-reply@${props.domainStack.mailDomainName}`,
          },
          secrets: {
            DB_USERNAME: ecs.Secret.fromSecretsManager(
              props.databaseStack.secret,
              "username",
            ),
            DB_PASSWORD: ecs.Secret.fromSecretsManager(
              props.databaseStack.secret,
              "password",
            ),
            SMTP_USERNAME: ecs.Secret.fromSecretsManager(
              props.domainStack.smptSecret,
              "username",
            ),
            SMTP_PASSWORD: ecs.Secret.fromSecretsManager(
              props.domainStack.smptSecret,
              "password",
            ),
          },
          logDriver: new ecs.AwsLogDriver({ streamPrefix: "rails-app" }),
        },
      },
    );

    this.fargateAlb.service.taskDefinition.addToTaskRolePolicy(
      new iam.PolicyStatement({
        actions: ["ses:SendEmail", "ses:SendRawEmail"],
        resources: ["*"],
      }),
    );

    props.databaseStack.secret.grantRead(
      this.fargateAlb.taskDefinition.taskRole,
    );

    props.domainStack.smptSecret.grantRead(
      this.fargateAlb.taskDefinition.taskRole,
    );

    new cdk.CfnOutput(this, "RailsAppUrl", {
      value: props.domainStack.applicationDomainName,
      description: "The url of your deployed Rails app",
    });

    new cdk.CfnOutput(this, "RailsAppClusterArn", {
      value: this.cluster.clusterArn,
      description: "The ARN of your Rails app's ECS cluster",
    });

    new cdk.CfnOutput(this, "RailsAppServiceArn", {
      value: this.fargateAlb.service.serviceArn,
      description: "The ARN of your Rails app's ECS service",
    });

    new cdk.CfnOutput(this, "DeploymentRegion", {
      value: props.env?.region ?? "null",
      description: "The AWS region of your deployment",
    });
  }
}
