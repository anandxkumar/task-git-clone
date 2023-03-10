#!/usr/bin/env bats

source ./test/helper/helper.sh

prepare_sh="./scripts/prepare.sh"

export PARAMS_URL="http://github.com/org/project.git"
export PARAMS_REVISION="main"
export PARAMS_VERBOSE="true"

@test "[prepare.sh] should fail when mandatory configuration is not informed" {
	unset PARAMS_URL
	unset PARAMS_REVISION
	unset WORKSPACES_OUTPUT_PATH

	run bash --posix ${prepare_sh}
	assert_failure
}

@test "[prepare.sh] should be able to copy files from 'basic-auth' workspace" {
	[ -n "${BASE_DIR}" ]

	export PARAMS_USER_HOME="${BASE_DIR}"
	export WORKSPACES_OUTPUT_PATH="${BASE_DIR}/workspaces/output"
	export WORKSPACES_BASIC_AUTH_BOUND="true"
	export WORKSPACES_BASIC_AUTH_PATH="${BASE_DIR}/workspaces/basic-auth"

	run mkdir -pv ${WORKSPACES_OUTPUT_PATH} ${WORKSPACES_BASIC_AUTH_PATH}
	assert_success

	# without the required files in place, the script should fail informing what's missing
	run bash --posix ${prepare_sh}
	assert_failure
	assert_output --partial 'not found'

	# creating the files expected for git basic authentication
	run touch ${WORKSPACES_BASIC_AUTH_PATH}/{.git-credentials,.gitconfig}
	assert_success

	# running the prepare script to copy over the expected files
	run bash --posix ${prepare_sh}
	assert_success

	# asserting the exected files are on the user home directory
	assert_file_exists "${PARAMS_USER_HOME}/.git-credentials"
	assert_file_exists "${PARAMS_USER_HOME}/.gitconfig"
}

@test "[prepare.sh] should be able to copy dot-ssh from 'ssh-directory' workspace" {
	[ -n "${BASE_DIR}" ]

	export PARAMS_USER_HOME="${BASE_DIR}"
	export WORKSPACES_OUTPUT_PATH="${BASE_DIR}/workspaces/output"
	export WORKSPACES_SSH_DIRECTORY_BOUND="true"
	export WORKSPACES_SSH_DIRECTORY_PATH="${BASE_DIR}/workspaces/ssh-directory"

	run mkdir -pv ${WORKSPACES_OUTPUT_PATH}
	assert_success

	# without the required worksapce, the script should fail, showing what's missing
	run bash --posix ${prepare_sh}
	assert_failure
	assert_output --partial 'not found'

	# creating the workspace directory and popating with a single file
	run mkdir -pv ${WORKSPACES_SSH_DIRECTORY_PATH}
	assert_success
	run touch ${WORKSPACES_SSH_DIRECTORY_PATH}/file
	assert_success

	# making sure the prepare script returns success
	run bash --posix ${prepare_sh}
	assert_success

	# asserting the expected file is copied
	assert_file_exists "${PARAMS_USER_HOME}/.ssh/file"
}

@test "[prepare.sh] should clean up the 'output' workspace" {
	[ -n "${BASE_DIR}" ]

	export PARAMS_USER_HOME="${BASE_DIR}"
	export PARAMS_DELETE_EXISTING="true"
	export WORKSPACES_OUTPUT_PATH="${BASE_DIR}/workspaces/output"

	# populating the output workspace with directories and empty files
	run mkdir -pv "${WORKSPACES_OUTPUT_PATH}/a/b"
	assert_success
	run touch ${WORKSPACES_OUTPUT_PATH}/{file1,file2,file3} ${WORKSPACES_OUTPUT_PATH}/a/file4
	assert_success

	# the prepare script should not return error
	run bash --posix ${prepare_sh}
	assert_success

	# asserting the output workspace is cleaned up, using find to confirm it's empty
	run find ${WORKSPACES_OUTPUT_PATH} -empty -exec echo empty \;
	assert_success
	assert_output 'empty'
}
