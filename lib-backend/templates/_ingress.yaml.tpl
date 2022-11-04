{{- define "lib-backend.ingress" -}}
{{- if default .Values.ingressEnabled false }}
{{- $fullName := include "lib-backend.fullname" . -}}
{{- $path := .Values.ingressPath | default (printf "/api/%s" $fullName) -}}
{{- $platformDomain := include "lib-backend.lookup.clusterDomain" . -}}
{{- $platformDomainOrigin := include "lib-backend.lookup.clusterDomainOrigin" . -}}
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: {{ $fullName }}
  labels:
    {{- include "lib-backend.labels" . | nindent 4 }}
  annotations:
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt
    konghq.com/https-redirect-status-code: "301"
    konghq.com/protocols: https
    konghq.com/strip-path: "true"
    konghq.com/regex-priority: "0"

spec:
  ingressClassName: kong
  tls:
    - hosts:
      - {{ $platformDomain }} # taken from {{ $platformDomainOrigin }}
      secretName: platform-tls
  rules:
    - host: {{ $platformDomain }} # taken from {{ $platformDomainOrigin }}
      http:
        paths:
          - path: {{ $path }}
            pathType: Prefix
            backend:
              service:
                name: {{ $fullName }}
                port:
                  number: 80
{{- end}}
{{- end}}
