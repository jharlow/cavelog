
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as route53 from 'aws-cdk-lib/aws-route53';
import * as certificatemanager from 'aws-cdk-lib/aws-certificatemanager';
import { CaveLogVpcStack } from "./cavelog-vpc-stack";

type DomainStackProps = { domainName: string, subdomain?: string, vpcStack: CaveLogVpcStack };

export class CaveLogDomainStack extends cdk.Stack {
  public readonly hostedZone: route53.IHostedZone;
  public readonly certificate: certificatemanager.Certificate;
  public readonly applicationDomainName: string

  constructor(scope: Construct, id: string, props: cdk.StackProps & DomainStackProps) {
    super(scope, id, props);

    this.applicationDomainName = `${props.subdomain}${props.subdomain ? "." : ""}${props.domainName}`

    this.hostedZone = route53.HostedZone.fromLookup(this, 'HostedZone', {
      domainName: props.domainName,
      privateZone: false,
    });

    this.certificate = new certificatemanager.Certificate(this, `${props.subdomain ?? 'main'}-Certificate`, {
      domainName: this.applicationDomainName,
      validation: certificatemanager.CertificateValidation.fromDns(this.hostedZone),
    });
  }

}
