{{- define "lib-backend.deployment.replicas" }}
{{- if .Values.replicas }}{{ .Values.replicas}}
{{- else }}1{{- end}}
{{- end }}


{{- define  "lib-backend.deployment.resources" }}
{{- if .Values.resources }}
resources:
  {{- .Values.resources | toYaml | nindent 2}}
{{- else}}
# no resources requirement
{{- end }}
{{- end }}
