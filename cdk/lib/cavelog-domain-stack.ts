import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as ses from "aws-cdk-lib/aws-ses";
import * as certificatemanager from "aws-cdk-lib/aws-certificatemanager";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import { SesSmtpCredentials } from "@pepperize/cdk-ses-smtp-credentials";
import { CaveLogVpcStack } from "./cavelog-vpc-stack";
import { User } from "aws-cdk-lib/aws-iam";
import { ok } from "assert";

type DomainStackProps = {
  domainName: string;
  subdomain?: string;
  vpcStack: CaveLogVpcStack;
};

export class CaveLogDomainStack extends cdk.Stack {
  public readonly hostedZone: route53.IHostedZone;
  public readonly certificate: certificatemanager.Certificate;
  public readonly applicationDomainName: string;
  public readonly mailDomainName: string;
  public readonly emailIdentity: ses.EmailIdentity;
  public readonly smptSecret: secretsmanager.ISecret;

  constructor(
    scope: Construct,
    id: string,
    props: cdk.StackProps & DomainStackProps,
  ) {
    super(scope, id, props);
    ok(props.env?.region);

    this.applicationDomainName = `${props.subdomain}${props.subdomain ? "." : ""}${props.domainName}`;
    this.mailDomainName = `mail.${props.domainName}`;

    this.hostedZone = route53.HostedZone.fromLookup(this, "HostedZone", {
      domainName: props.domainName,
      privateZone: false,
    });

    this.certificate = new certificatemanager.Certificate(
      this,
      `${props.subdomain ?? "main"}-Certificate`,
      {
        domainName: this.applicationDomainName,
        validation: certificatemanager.CertificateValidation.fromDns(
          this.hostedZone,
        ),
      },
    );

    this.emailIdentity = new ses.EmailIdentity(this, "EmailIdentity", {
      identity: ses.Identity.email(props.domainName),
      dkimSigning: true,
      mailFromDomain: this.mailDomainName,
    });

    new route53.CfnRecordSet(this, "EmailDKIMRecord1", {
      hostedZoneId: this.hostedZone.hostedZoneId,
      name: this.emailIdentity.dkimDnsTokenName1,
      resourceRecords: [this.emailIdentity.dkimDnsTokenValue1],
      ttl: "300",
      type: "CNAME",
    });

    new route53.CfnRecordSet(this, "EmailDKIMRecord2", {
      hostedZoneId: this.hostedZone.hostedZoneId,
      name: this.emailIdentity.dkimDnsTokenName2,
      resourceRecords: [this.emailIdentity.dkimDnsTokenValue2],
      ttl: "300",
      type: "CNAME",
    });

    new route53.CfnRecordSet(this, "EmailDKIMRecord3", {
      hostedZoneId: this.hostedZone.hostedZoneId,
      name: this.emailIdentity.dkimDnsTokenName3,
      resourceRecords: [this.emailIdentity.dkimDnsTokenValue3],
      ttl: "300",
      type: "CNAME",
    });

    new route53.TxtRecord(this, "EmailTXTRecord1", {
      zone: this.hostedZone,
      recordName: `_dmarc.${props.domainName}`,
      values: ["v=DMARC1; p=none;"],
    });

    new route53.TxtRecord(this, "MailFromTXTRecord", {
      zone: this.hostedZone,
      recordName: `mail.${props.domainName}`,
      values: ["v=spf1 include:amazonses.com ~all"],
    });

    /**
     * @see https://docs.aws.amazon.com/general/latest/gr/ses.html#ses_feedback_endpoints
     */
    new route53.CfnRecordSet(this, "MXRecord", {
      hostedZoneId: this.hostedZone.hostedZoneId,
      name: this.mailDomainName,
      type: "MX",
      ttl: "60",
      resourceRecords: [`10 feedback-smtp.${props.env.region}.amazonses.com`],
    });

    const user = new User(this, "SesUser", { userName: "ses-user" });
    const smtp = new SesSmtpCredentials(this, "SmtpCredentials", { user });
    this.smptSecret = smtp.secret;
  }
}
