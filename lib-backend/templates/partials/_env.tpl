{{- define "lib-backend.env.spec" -}}
{{- $version := include "lib-backend.lookup.clusterVersion" . }}
{{- if eq $version "v1"}}
{{- include "lib-backend.env-v1.spec" . }}
{{- else if eq $version "deprecated"}}
{{- include "lib-backend.env-deprecated.spec" . }}
{{- else }}
{{ fail (printf "Unknown clusterVersion '%s'" $version )  }}
{{- end}}
{{- end }}
