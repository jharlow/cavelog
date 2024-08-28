import * as assert from "assert";

export const assertAndReturn = <T>(u?: T, description?: string): T => {
  assert(
    u,
    description
      ? `${description} does not exist`
      : "Asserted value did not exist",
  );

  return u;
};
