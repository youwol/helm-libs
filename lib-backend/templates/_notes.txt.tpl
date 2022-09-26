{{- define "lib-backend.notes" -}}
{{- $name := .Release.Name}}
{{- $ins := .Release.IsInstall}}
{{- $up := .Release.IsUpgrade}}
{{- $rev := .Release.Revision}}
{{- $v := .Chart.AppVersion}}
{{- $ns := .Release.Namespace}}
{{- $fullname := include "lib-backend.fullname" .}}
{{- $fqdn := printf "%s.%s.svc.cluster.local" $fullname $ns}}
** {{ .Chart.Name }}-{{ .Chart.Version }} ({{ include "lib-backend.notes.selfNameVersion" . }}) **
{{ if $ins -}}Installing release '{{ $name }}' of app version {{ $v }} into namespace '{{ $ns }}'.{{ end -}}
{{ if $up -}}Upgrading release '{{ $name }}' to revision {{ $rev }} for app version {{ $v }}.{{ end -}}
{{ ""}}
Deployment in cluster version '{{ include "lib-backend.lookup.clusterVersion" .}}' use configMaps and secrets for {{ join ", " .Values.env}}.
{{ include "lib-backend.image.notes" . }}

Service FQDN is '{{ $fqdn }}'. To forward access to this service on your post :
$  kubectl --namespace {{ $ns }} port-forward svc/{{ $fullname }} 8080:80

{{if default .Values.ingressEnabled false -}}
{{- $fullName := include "lib-backend.fullname" . -}}
{{- $path := .Values.ingressPath | default (printf "/api/%s" $fullName) -}}
{{- $platformDomain := include "lib-backend.lookup.clusterDomain" . -}}
{{- $uri := printf "https://%s%s" $platformDomain $path -}}
Using domain '{{ $platformDomain }}' from {{ include "lib-backend.lookup.clusterDomainOrigin" . }}, public endpoint is :
{{ $uri }}
{{- end}}
{{- end }}

{{- define "lib-backend.notes.selfNameVersion"}}
{{- range .Chart.Dependencies }}
{{- with fromJson (toJson .) }}
{{- if eq .name "lib-backend"}}
{{- printf "%s-%s" .name .version }}
{{- end }}
{{- end }}
{{- end}}
{{- end}}
