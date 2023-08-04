{{- define "lib-backend.deployment" -}}
{{ $probeSecret := randAlphaNum 16 | quote }}
apiVersion: apps/v1
kind: Deployment

metadata:
  name: {{ include "lib-backend.fullname" . }}
  labels:
    {{- include "lib-backend.labels" . | nindent 4 }}

spec:
  replicas: {{ include "lib-backend.deployment.replicas" . }}
  selector:
    matchLabels:
      {{- include "lib-backend.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "lib-backend.selectorLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "lib-backend.fullname" . }}
      containers:
        - name: {{ .Chart.Name }}
          {{- include "lib-backend.image.spec" . | indent 10 }}
          {{- include "lib-backend.deployment.resources" . | indent 10 }}
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          readinessProbe:
            httpGet:
              port: 8080
              path: /observability/readiness
          livenessProbe:
            httpGet:
              port: 8080
              path: /observability/liveness
          startupProbe:
            httpGet:
              port: 8080
              path: /observability/startup
          env:
            {{- include "lib-backend.probeSecret.env" (dict "root" . "value" $probeSecret) | nindent 12 }}
            {{- include "lib-backend.env.spec" . | nindent 12 }}

{{- end -}}
