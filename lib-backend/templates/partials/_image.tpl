{{- define "lib-backend.image.spec" -}}
{{- $tag := .Values.imageTag | default .Chart.AppVersion }}
image: {{ printf "registry.gitlab.com/youwol/platform/backends:%s" $tag | quote -}}
{{- if .Values.imagePullPolicy }}
# Specified image policy
imagePullPolicy: {{ .Values.imagePullPolicy }} # Explicitly specified image policy
{{- else }}
{{- if hasSuffix "-wip" .Chart.AppVersion }}
imagePullPolicy: Always # Always pull image since AppVersion end with "-wip"
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "lib-backend.image.notes" -}}
{{- $tag := .Values.imageTag | default .Chart.AppVersion }}
{{- $url := printf "registry.gitlab.com/youwol/platform/backends:%s" $tag | quote }}
{{- $descExplicitPullPolicy := printf "using explicit pull policy '%s'" .Values.imagePullPolicy }}
{{- $descPullPolicyWip := "using pull policy 'Always' since AppVersion end with '-wip'" }}
{{- $descDefaultPolicy := (eq $tag "latest") | ternary "'Always' since tag is 'latest'" "'IfNotPresent'"}}
{{- $descUnspecifiedPolicy := printf "without specifying pull policy (will default to %s)" $descDefaultPolicy}}
Image will be pulled from {{ $url }},{{ if .Values.imagePullPolicy }} {{ $descExplicitPullPolicy }}.
{{- else -}}{{ if hasSuffix "-wip" .Chart.AppVersion }} {{$descPullPolicyWip}}.
{{- else }} {{$descUnspecifiedPolicy}}.{{- end -}}
{{- end -}}
{{- end -}}

{{- define "lib-backend.image.args" -}}
{{- $args := .Values.containerArgs | default (list .Chart.Name) -}}
{{- range $args }}
- {{ . }}
{{- end }}
{{- end -}}
