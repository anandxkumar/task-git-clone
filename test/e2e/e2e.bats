#!/usr/bin/env bats

source ./test/helper/helper.sh

@test "" {
	[ -n "${BASE_DIR}" ]

	run kubectl delete taskrun --all
	assert_success

	run tkn task start git-clone \
		--param="URL=https://github.com/tektoncd/community.git" \
		--param="REVISION=main" \
		--param="DEPTH=1" \
		--param="VERBOSE=true" \
		--use-param-defaults \
		--workspace="name=output,emptyDir=" \
		--skip-optional-workspace \
		--showlog >&3
	assert_success

	#
	# Asserting TaskRun Status
	#

	readonly tmpl_file="${BASE_DIR}/go-template.tpl"

	cat >${tmpl_file} <<EOS
{{- range .status.conditions -}}
  {{- if and (eq .type "Succeeded") (eq .status "True") }}
    {{ .message }}
  {{- end }}
{{- end -}}
EOS

	run tkn taskrun describe --output=go-template-file --template=${tmpl_file}
	assert_success
	assert_success --partial 'All Steps have completed executing'

	#
	# Asserting Results
	#

	cat >${tmpl_file} <<EOS
{{- range .status.taskResults -}}
  {{ printf "%s=%s\n" .name .value }}
{{- end -}}
EOS
	run tkn taskrun describe --output=go-template-file --template=${tmpl_file}
	assert_success
	assert_output --regexp $'^COMMIT=\S+\nCOMMITTER_DATE=\S+\nURL=\S+.*'
}
