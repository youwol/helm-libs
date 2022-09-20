{{- define "lib-backend.lookup.clusterDomain" }}
{{- $clusterConfig := (lookup "v1" "ConfigMap" "apps" "cluster-config") }}
{{- if $clusterConfig }}
{{- $clusterConfig.data.clusterDomain }}
{{- else}}
{{- required "configmap «cluster-config» not found and no platformDomain defined" .Values.platformDomain }}
{{- end }}
{{- end }}

{{- define "lib-backend.lookup.clusterVersion" }}
{{- $clusterConfig := (lookup "v1" "ConfigMap" "apps" "cluster-config") }}
{{- if $clusterConfig }}
{{- $clusterConfig.data.version | default "deprecated"  }}
{{- else}}
{{- required "configmap «cluster-config» not found and no clusterVersion defined" .Values.clusterVersion }}
{{- end }}
{{- end }}

{{- define "lib-backend.lookup.clusterDomainOrigin" -}}
{{- $clusterConfig := (lookup "v1" "ConfigMap" "apps" "cluster-config") }}
{{- if $clusterConfig }}configMap cluster-config.clusterDomain{{ else }}values{{ end }}
{{- end }}
