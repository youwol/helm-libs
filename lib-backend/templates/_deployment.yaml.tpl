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
      {{- if .Values.tempVolume }}
      volumes:
        - name: temp
          emptyDir:
            medium: Memory
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          {{- include "lib-backend.image.spec" . | indent 10 }}
          args:
            {{- include "lib-backend.image.args" . | indent 12 }}
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          securityContext:
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 10000
            runAsGroup: 10000
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
            {{- include "lib-backend.env.spec" . | nindent 12 }}
          {{- include "lib-backend.deployment.resources" . | indent 10 }}
          {{- if .Values.tempVolume }}
          volumeMounts:
            - mountPath: /tmp
              name: temp
          {{- end }}

{{- end -}}
