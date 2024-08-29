import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";
import { CaveLogDatabaseStack } from "./cavelog-db-stack";
import { AppEnvProps, CaveLogAppStack } from "./cavelog-app-stack";

export class CaveLogStack extends cdk.Stack {
  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & AppEnvProps,
  ) {
    super(scope, id, props);

    const vpc = new CaveLogVpcStack(this, "VpcStack", props);

    const db = new CaveLogDatabaseStack(this, "DatabaseStack", {
      ...props,
      vpcStack: vpc,
    });

    new CaveLogAppStack(this, "AppStack", {
      ...props,
      vpcStack: vpc,
      databaseStack: db,
    });
  }
}
