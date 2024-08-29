#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { CaveLogStack } from "../lib/cavelog-cdk-stack";
import { assertAndReturn } from "../lib/assert-and-return";
import * as dotenv from "dotenv";
import { getCaveLogAppStackPropsFromEnvrionment } from "../lib/cavelog-app-stack";

dotenv.config();

const app = new cdk.App();

new CaveLogStack(app, "CaveLogStack", {
  env: {
    account: assertAndReturn(process.env.CDK_ACCOUNT, "CDK_ACCOUNT"),
    region: assertAndReturn(process.env.CDK_REGION, "CDK_REGION"),
  },
  ...getCaveLogAppStackPropsFromEnvrionment(),
});
