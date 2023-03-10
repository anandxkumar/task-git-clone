#!/usr/bin/env sh
#
# Scan the cloned repository in order to report details writting the result files.
#

set -eu

source $(CDPATH= cd -- "$(dirname -- ${0})" && pwd)/common.sh

assert_required_configuration_or_fail

phase "Collecting cloned repository information ('${checkout_dir}')"

cd "${checkout_dir}" || fail "Not able to enter checkout-dir '${checkout_dir}'"

phase "Setting output workspace as safe directory ('${WORKSPACES_OUTPUT_PATH}')"
git config --global --add safe.directory "${WORKSPACES_OUTPUT_PATH}"

result_sha="$(git rev-parse HEAD)"
result_committer_date="$(git log -1 --pretty=%ct)"

phase "Reporting last commit date '${result_committer_date}'"
printf "%s" "${result_committer_date}" >${RESULTS_COMMITTER_DATE_PATH}

phase "Reporting parsed revision SHA '${result_sha}'"
printf "%s" "${result_sha}" >${RESULTS_COMMIT_PATH}

phase "Reporting repository URL '${PARAMS_URL}'"
printf "%s" "${PARAMS_URL}" >${RESULTS_URL_PATH}

exit 0