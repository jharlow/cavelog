import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";
import { CaveLogDatabaseStack } from "./cavelog-db-stack";
import { AppEnvProps, CaveLogAppStack } from "./cavelog-app-stack";
import { CaveLogDomainStack } from "./cavelog-domain-stack";

export class CaveLogStack extends cdk.Stack {
  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & AppEnvProps,
  ) {
    super(scope, id, props);

    const vpcStack = new CaveLogVpcStack(this, "VpcStack", props);

    const domainStack = new CaveLogDomainStack(this, "DomainStack", {
      ...props,
      domainName: "cavelog.org",
      subdomain: "alpha",
      vpcStack,
    });

    const databaseStack = new CaveLogDatabaseStack(this, "DatabaseStack", {
      ...props,
      vpcStack: vpcStack,
    });

    new CaveLogAppStack(this, "AppStack", {
      ...props,
      vpcStack,
      databaseStack,
      domainStack,
    });
  }
}
