{{- define "lib-backend.deployment" -}}
{{ $probeSecret := randAlphaNum 16 | quote }}
apiVersion: apps/v1
kind: Deployment

metadata:
  name: {{ include "lib-backend.fullname" . }}
  labels:
    {{- include "lib-backend.labels" . | nindent 4 }}

spec:
  replicas: 1
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
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
              {{- with include "lib-backend.probeSecret.probeHttpHeaders" (dict "root" . "value" $probeSecret) }}
              httpHeaders:
                {{- . | nindent 16 }}
              {{- end }}
            initialDelaySeconds: 15
            periodSeconds: 15
            timeoutSeconds: 5
            failureThreshold: 3
          env:
            {{- include "lib-backend.probeSecret.env" (dict "root" . "value" $probeSecret) | nindent 12 }}
            {{- include "lib-backend.env.spec" . | nindent 12 }}
{{- end -}}
