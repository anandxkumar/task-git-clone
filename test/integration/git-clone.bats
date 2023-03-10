#!/usr/bin/env bats

source ./test/helper/helper.sh

git_clone_sh="./scripts/git-clone.sh"

# mocked binaries directory
mock_bin="${PWD}/test/mock/bin"

@test "[git-clone.sh] should pick ssl-ca-directory workspace" {
	export PARAMS_URL="http://github.com/org/project.git"
	export PARAMS_REVISION="main"
	export PARAMS_VERBOSE="true"

	export PARAMS_CRT_FILENAME="ca-bundle.crt"
	export PARAMS_DEPTH=""
	export PARAMS_HTTP_PROXY=""
	export PARAMS_HTTPS_PROXY=""
	export PARAMS_NO_PROXY=""
	export PARAMS_REFSPEC=""
	export PARAMS_SPARSE_CHECKOUT_DIRECTORIES=""
	export PARAMS_SSL_VERIFY=""
	export PARAMS_SUBDIRECTORY=""
	export PARAMS_SUBMODULES=""

	export WORKSPACES_OUTPUT_PATH="${BASE_DIR}/workspaces/output"
	export WORKSPACES_SSL_CA_DIRECTORY_BOUND="true"
	export WORKSPACES_SSL_CA_DIRECTORY_PATH="${BASE_DIR}/workspaces/ssl-ca-directory"

	# making sure the mocked executables are invoked
	export PATH="${mock_bin}:${PATH}"

	# creating the workspaces
	run mkdir -pv ${WORKSPACES_OUTPUT_PATH} ${WORKSPACES_SSL_CA_DIRECTORY_PATH}
	assert_success

	# should fail when the ssl-ca-directory is incomplete, in this case the ssl-ca-directory
	# workspace does not contain the file configured in the PARAMS_CRT_FILENAME
	run bash --posix ${git_clone_sh}
	assert_failure

	# creating the configured file on the workspace
	run touch "${WORKSPACES_SSL_CA_DIRECTORY_PATH}/${PARAMS_CRT_FILENAME}"
	assert_success

	# with all requriements in place the git-clone script succeeds
	run bash --posix ${git_clone_sh}
	assert_success
}
