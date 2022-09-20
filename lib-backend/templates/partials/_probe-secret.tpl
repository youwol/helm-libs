{{- define "lib-backend.probeSecret.probeHttpHeaders" -}}
{{- if .root.Values.probeSecret -}}
# HTTP header for probe secret
- name: x-k8s-probe-secret
  value: {{ .value }}
{{- end -}}
{{- end -}}

{{- define "lib-backend.probeSecret.env" -}}
{{- if .root.Values.probeSecret -}}
# Environment variable for probe secret
- name: K8S_PROBE_SECRET
  value: {{ .value }}
{{- else -}}
# No environment variable for probe secret
{{- end -}}
{{- end -}}
