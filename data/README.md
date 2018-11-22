# Overview

This module uses the same inputs and outputs as the main ECS module, but only
as a data block rather than actually creating resources.  This allows us to
use the return output from the ECS module in other modules without having to
pass each output value separately.

Yes, there's currently only one such value, but this is a pattern that's very
useful in other places, and we want to keep using that pattern.

# Variables

See variables.tf for all current variables and descriptions.

### Resources
- data aws_iam_role (execution role)

# Outputs

See output.tf for all current outputs.
