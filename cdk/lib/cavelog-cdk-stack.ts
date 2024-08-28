import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
import * as rds from "aws-cdk-lib/aws-rds";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import * as opensearchservice from "aws-cdk-lib/aws-opensearchservice";
import { assertAndReturn } from "./assert-and-return";
import * as ecr from "aws-cdk-lib/aws-ecr-assets";
import { AnyPrincipal, PolicyStatement } from "aws-cdk-lib/aws-iam";
// import * as s3 from "aws-cdk-lib/aws-s3";
// import * as s3_deployment from "aws-cdk-lib/aws-s3-deployment";

export type CaveLogStackProps = {
  railsMasterKey: string;
  googleMapsApiKey: string;
};

export const getCaveLogStackPropsFromEnvrionment = (): CaveLogStackProps => ({
  railsMasterKey: assertAndReturn(
    process.env.RAILS_MASTER_KEY,
    "RAILS_MASTER_KEY",
  ),
  googleMapsApiKey: assertAndReturn(
    process.env.GOOGLE_MAPS_API_KEY,
    "GOOGLE_MAPS_API_KEY",
  ),
});

export class CaveLogStack extends cdk.Stack {
  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & CaveLogStackProps,
  ) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, "MyVpc", {
      maxAzs: 3,
      subnetConfiguration: [
        {
          subnetType: ec2.SubnetType.PUBLIC,
          name: "CavelogPublicSubnet",
          cidrMask: 24,
        },
        {
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
          name: "CavelogPrivateSubnet",
          cidrMask: 24,
        },
      ],
    });

    const dbSecurityGroup = new ec2.SecurityGroup(this, "DBSecurityGroup", {
      vpc,
      description: "Allow access to RDS from Fargate",
      allowAllOutbound: true,
    });

    // Allow inbound traffic on the RDS port from the Fargate task's security group
    dbSecurityGroup.addIngressRule(
      ec2.Peer.anyIpv4(), // Adjust this to use the security group of the Fargate task
      ec2.Port.tcp(5432), // PostgreSQL default port
      "Allow PostgreSQL access",
    );

    const dbSecret = new secretsmanager.Secret(this, "DBSecret", {
      secretName: "my-db-secret",
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: "postgres" }),
        generateStringKey: "password",
        excludePunctuation: true,
      },
    });

    const db = new rds.DatabaseInstance(this, "PostgresDB", {
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_14,
      }),
      vpc,
      credentials: rds.Credentials.fromSecret(dbSecret),
      multiAz: false,
      allocatedStorage: 100,
      maxAllocatedStorage: 200,
      vpcSubnets: { subnetType: ec2.SubnetType.PUBLIC },
      publiclyAccessible: true,
    });

    db.connections.addSecurityGroup(dbSecurityGroup);

    const esSecurityGroup = new ec2.SecurityGroup(this, "ESSecurityGroup", {
      vpc,
      description: "Allow access to OpenSearch from Fargate",
      allowAllOutbound: true,
    });

    const esDomain = new opensearchservice.Domain(this, "ElasticsearchDomain", {
      version: opensearchservice.EngineVersion.OPENSEARCH_2_5,
      ebs: { volumeSize: 10, volumeType: ec2.EbsDeviceVolumeType.GP3 },
      vpc,
      zoneAwareness: { availabilityZoneCount: 3 },
      capacity: { dataNodes: 3, masterNodes: 3 },
      vpcSubnets: [
        vpc.selectSubnets({ subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS }),
      ],
      nodeToNodeEncryption: true,
      securityGroups: [esSecurityGroup],
    });

    // Allow inbound traffic on the RDS port from the Fargate task's security group
    esSecurityGroup.addIngressRule(
      ec2.Peer.anyIpv4(), // Adjust this to use the security group of the Fargate task
      ec2.Port.tcp(9200), // OpenSearch default port
      "Allow PostgreSQL access",
    );

    const cluster = new ecs.Cluster(this, "RailsCluster", { vpc });

    const fargateSecurityGroup = new ec2.SecurityGroup(
      this,
      "FargateSecurityGroup",
      {
        vpc,
        description:
          "Allow Fargate tasks to communicate with RDS and OpenSearch",
        allowAllOutbound: true,
      },
    );

    // Allow outbound traffic to RDS
    fargateSecurityGroup.connections.allowTo(
      dbSecurityGroup,
      ec2.Port.tcp(5432),
      "Allow outbound RDS access",
    );

    // Allow outbound traffic to OpenSearch
    fargateSecurityGroup.connections.allowTo(
      esSecurityGroup,
      ec2.Port.tcp(9200),
      "Allow outbound OpenSearch access",
    );

    const appTaskDefinition = new ecs.FargateTaskDefinition(this, "AppTaskDef");
    appTaskDefinition.addContainer("RailsAppContainer", {
      image: ecs.ContainerImage.fromAsset("../", {
        file: "Dockerfile",
        platform: ecr.Platform.LINUX_AMD64,
      }),
      logging: new ecs.AwsLogDriver({ streamPrefix: "rails-app" }),
      secrets: {
        DB_USERNAME: ecs.Secret.fromSecretsManager(dbSecret, "username"),
        DB_PASSWORD: ecs.Secret.fromSecretsManager(dbSecret, "password"),
      },
      environment: {
        DB_DATABASE: "postgres",
        DB_TIMEOUT: "5000",
        DB_PORT: "5432",
        DB_HOST: db.dbInstanceEndpointAddress,
        ELASTICSEARCH_HOST: esDomain.domainEndpoint,
        ELASTICSEARCH_PORT: "9200",
        GOOGLE_MAPS_API_KEY: props.googleMapsApiKey,
        RAILS_ENV: "production",
        RAILS_SERVE_STATIC_FILES: "true",
        RAILS_LOG_TO_STDOUT: "true",
        RAILS_MASTER_KEY: props.railsMasterKey,
      },
      portMappings: [{ containerPort: 3000 }],
    });

    db.connections.allowFrom(
      fargateSecurityGroup,
      ec2.Port.tcp(5432),
      "Allow Fargate to connect to RDS",
    );

    esDomain.connections.allowFrom(
      fargateSecurityGroup,
      ec2.Port.tcp(443),
      "Allow Fargate to connect to OpenSearch",
    );

    dbSecret.grantRead(appTaskDefinition.taskRole);

    new ecs_patterns.ApplicationLoadBalancedFargateService(
      this,
      "RailsAppService",
      {
        cluster,
        taskDefinition: appTaskDefinition,
        desiredCount: 1,
        publicLoadBalancer: true,
        listenerPort: 80,
        securityGroups: [fargateSecurityGroup],
        enableExecuteCommand: true,
      },
    );
  }
}
