#!/bin/bash

# Fail fast
set -eo pipefail

# Set tmp files to be deleted on script end.
trap 'rm -rf "$TRANSFORM_YAML" "$TEMP_TEST_DIR"' EXIT

# =============== Source substitution =============== #
# Specify some artificial value for listener:
export LISTENER_IP="0.0.0.0"
export LISTENER_PORT="9000"

TRANSFORM_YAML=$(mktemp -t kirkos_aws_transforms.XXXXXXXXXX.yaml)
envsubst < config/aws_transforms.yaml > "$TRANSFORM_YAML"

unset LISTENER_IP LISTENER_PORT

# ============== Unit test substitution ============== #
# Strip out newlines and whitespace. 
# Otherwise Vector will process line-by-line and fail due to incomplete JSON.
export CLOUDTRAIL_SINGLE_LOG=$(cat tests/payloads/cloudtrail_records_array.json | tr -d "\n\r")
export CLOUDTRAIL_RECORDS_ARRAY=$(cat tests/payloads/cloudtrail_single_log.json | tr -d "\n\r")
export GUARDDUTY_RAW_LOG=$(cat tests/payloads/guardduty_raw_log.json | tr -d "\n\r")
export GUARDDUTY_EVENTBRIDGE_LOG=$(cat tests/payloads/guardduty_eventbridge_log.json | tr -d "\n\r")
export GUARDDUTY_FINDINGS_ARRAY=$(cat tests/payloads/guardduty_findings_array.json | tr -d "\n\r")

# Create a temporary directory to house test files.
TEMP_TEST_DIR=$(mktemp -d -t kirkos_unit_tests.XXXXXXXXXX)
for test_file in tests/*.yaml; do
  filename=$(basename "$test_file")
  envsubst < "$test_file" > "$TEMP_TEST_DIR/$filename"
done

# ================ Unit test execution =============== #
# Use -qq to suppress warnings.
vector -qq test "$TRANSFORM_YAML" "$TEMP_TEST_DIR"/*.yaml