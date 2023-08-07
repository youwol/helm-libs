{{- define "lib-backend.service" -}}
apiVersion: v1
kind: Service

metadata:
  name: {{ include "lib-backend.fullname" . }}
  labels:
    {{- include "lib-backend.labels" . | nindent 4 }}

spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
    - port: 8001
      targetPort: 8001
      protocol: TCP
      name: monitor
  selector:
    {{- include "lib-backend.selectorLabels" . | nindent 4 }}
{{- end}}
