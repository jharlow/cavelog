import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as rds from "aws-cdk-lib/aws-rds";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";

type DatabaseStackProps = { vpcStack: CaveLogVpcStack };

export class CaveLogDatabaseStack extends cdk.Stack {
  public readonly secret: secretsmanager.Secret;
  public readonly database: rds.ServerlessCluster;
  public readonly databaseName: string;
  public readonly securityGroup: ec2.SecurityGroup;

  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & DatabaseStackProps,
  ) {
    super(scope, id, props);

    this.securityGroup = new ec2.SecurityGroup(this, "DBSecurityGroup", {
      vpc: props.vpcStack.vpc,
      description: "Allow access to RDS from Fargate",
    });

    this.secret = new secretsmanager.Secret(this, "DBSecret", {
      secretName: "my-db-secret",
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: "postgres" }),
        generateStringKey: "password",
        excludePunctuation: true,
      },
    });

    this.databaseName = "postgres";
    this.database = new rds.ServerlessCluster(this, "AuroraServerlessCluster", {
      engine: rds.DatabaseClusterEngine.auroraPostgres({
        version: rds.AuroraPostgresEngineVersion.VER_13_9,
      }),
      securityGroups: [this.securityGroup],
      vpc: props.vpcStack.vpc,
      credentials: rds.Credentials.fromSecret(this.secret),
      vpcSubnets: { subnetType: ec2.SubnetType.PUBLIC },
      defaultDatabaseName: this.databaseName,
    });

    this.securityGroup.addIngressRule(
      this.securityGroup,
      ec2.Port.tcp(this.database.clusterEndpoint.port),
      "Allow inbound traffic to RDS",
    );
  }
}
