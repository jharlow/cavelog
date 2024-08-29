import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";

export class CaveLogVpcStack extends cdk.Stack {
  public readonly vpc: ec2.Vpc;
  public readonly fargateSecurityGroup: ec2.SecurityGroup;

  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    this.vpc = new ec2.Vpc(this, "MyVpc", {
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
  }
}
