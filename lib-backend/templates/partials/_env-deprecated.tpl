{{- define "lib-backend.env-deprecated.spec" -}}
{{ if default .Values.env false -}}
{{- include "lib-backend.env-deprecated.openidBaseUrl" . -}}
{{- include "lib-backend.env-deprecated.openidClient" . -}}
{{- include "lib-backend.env-deprecated.keycloakAdmin" . -}}
{{- include "lib-backend.env-deprecated.redis" . -}}
{{- include "lib-backend.env-deprecated.minio" . -}}
{{- end -}}
{{- end -}}

{{- define "lib-backend.env-deprecated.openidBaseUrl" -}}
{{ if has "openidBaseUrl" .Values.env  -}}
# Environment variables for openidBaseUrl
- name: OPENID_BASE_URL
  valueFrom:
    configMapKeyRef:
      name: backend-env
      key: OPENID_BASE_URL
{{ end -}}
{{- end -}}

{{- define "lib-backend.env-deprecated.openidClient" -}}
{{ if has "openidClient" .Values.env -}}
# Environment variables for openidClient
{{ if not (has "openidBaseUrl" .Values.env) -}}
- name: OPENID_BASE_URL
  valueFrom:
    configMapKeyRef:
      name: backend-env
      key: OPENID_BASE_URL
{{ end -}}
- name: OPENID_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: openid-app-credentials
      key: client_id
- name: OPENID_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: openid-app-credentials
      key: client_secret
{{ end -}}
{{- end -}}

{{- define "lib-backend.env-deprecated.redis" -}}
{{ if has "redis" .Values.env -}}
# Environment variables for redis
- name: REDIS_HOST
  valueFrom:
    configMapKeyRef:
      name: backend-env
      key: REDIS_HOST
- name: REDIS_USERNAME
  valueFrom:
    secretKeyRef:
      name: redis-app-credentials
      key: username
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: redis-app-credentials
      key: password
{{ end -}}
{{- end -}}

{{- define "lib-backend.env-deprecated.minio" -}}
{{ if has "minio" .Values.env -}}
# Environment variables for minio
- name: MINIO_HOST
  valueFrom:
    configMapKeyRef:
      name: backend-env
      key: MINIO_HOST
- name: MINIO_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: minio-app-credentials
      key: access_key
- name: MINIO_ACCESS_SECRET
  valueFrom:
    secretKeyRef:
      name: minio-app-credentials
      key: access_secret
{{ end -}}
{{- end -}}

{{- define "lib-backend.env-deprecated.keycloakAdmin" -}}
{{ if has "keycloakAdmin" .Values.env -}}
# Environment variables for keycloakAdmin
- name: KEYCLOAK_ADMIN_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: keycloak-app-credentials
      key: admin_login
- name: KEYCLOAK_ADMIN_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: keycloak-app-credentials
      key: admin_password
- name: KEYCLOAK_ADMIN_BASE_URL
  valueFrom:
    configMapKeyRef:
      name: backend-env
      key: KEYCLOAK_ADMIN_BASE_URL
{{ end -}}
{{- end -}}
