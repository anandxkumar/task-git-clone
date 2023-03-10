#!/usr/bin/env sh
#
# Sets up the basic and SSH authentication based on informed workspaces, as well as cleaning up the
# privous git-clone data.
#

set -eu -o pipefail

source $(CDPATH= cd -- "$(dirname -- ${0})" && pwd)/common.sh

assert_required_configuration_or_fail

phase "Preparing the filesystem before cloning the repository"

if [[ "${WORKSPACES_BASIC_AUTH_BOUND}" == "true" ]]; then
	phase "Configuring Git authentication with 'basic-auth' Workspace files"

	for f in .git-credentials .gitconfig; do
		src="${WORKSPACES_BASIC_AUTH_PATH}/${f}"
		phase "Copying '${src}' to '${PARAMS_USER_HOME}'"
		copy_or_fail 400 ${src} "${PARAMS_USER_HOME}/"
	done
fi

if [[ "${WORKSPACES_SSH_DIRECTORY_BOUND}" == "true" ]]; then
	phase "Copying '.ssh' from ssh-directory workspace ('${WORKSPACES_SSH_DIRECTORY_PATH}')"

	dot_ssh="${PARAMS_USER_HOME}/.ssh"
	copy_or_fail 700 ${WORKSPACES_SSH_DIRECTORY_PATH} ${dot_ssh}
	chmod -Rv 400 ${dot_ssh}/*
fi

if [[ "${PARAMS_DELETE_EXISTING}" == "true" ]]; then
	phase "Deleting all contents of checkout-dir '${checkout_dir}'"
	clean_dir ${checkout_dir} || true
fi
