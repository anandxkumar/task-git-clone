{{- /*

  This template is meant to translate the Tekton placeholder utilized by the shell scripts, thus the
  scripts can rely on a pre-defined and repetable way of consuming Tekton attributes.

    Example:
      The placeholder `workspaces.a.b` becomes `WORKSPACES_A_B`

*/ -}}
{{- define "environment-variables" -}}
    {{- range list
          "params.URL"
          "params.REVISION"
          "params.REFSPEC"
          "params.SUBMODULES"
          "params.DEPTH"
          "params.SSL_VERIFY"
          "params.CRT_FILENAME"
          "params.SUBDIRECTORY"
          "params.SPARSE_CHECKOUT_DIRECTORIES"
          "params.DELETE_EXISTING"
          "params.HTTP_PROXY"
          "params.HTTPS_PROXY"
          "params.NO_PROXY"
          "params.VERBOSE"
          "params.GIT_INIT_IMAGE"
          "params.USER_HOME"
          "workspaces.output.path"
          "workspaces.ssh-directory.bound"
          "workspaces.ssh-directory.path"
          "workspaces.basic-auth.bound"
          "workspaces.basic-auth.path"
          "workspaces.ssl-ca-directory.bound"
          "workspaces.ssl-ca-directory.path"
          "results.COMMITTER_DATE.path"
          "results.COMMIT.path"
          "results.URL.path"
    }}
- name: {{ . | upper | replace "." "_" | replace "-" "_" }}
  value: "$({{ . }})"
    {{- end -}}
{{- end -}}