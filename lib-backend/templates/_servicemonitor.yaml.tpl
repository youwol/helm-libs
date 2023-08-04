{{- define "lib-backend.serviceMonitor" -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "lib-backend.fullname" . }}
spec:
  endpoints:
    - honorLabels: true
      path: /
      port: monitor
      scheme: http
  jobLabel: {{ include "lib-backend.fullname" . }}
  namespaceSelector:
    matchNames:
      - {{ .Release.Namespace }}
  selector:
    matchLabels:
{{- include "lib-backend.labels" . | nindent 6 }}
{{- end }}
