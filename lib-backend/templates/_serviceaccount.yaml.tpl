{{- define "lib-backend.serviceAccount" -}}
apiVersion: v1
kind: ServiceAccount

metadata:
  name: {{ include "lib-backend.fullname" . }}
  labels:
{{- include "lib-backend.labels" . | nindent 4 }}

imagePullSecrets:
- name: gitlab-docker
{{- end}}
