{{- define "lib-configuration.config-map"}}
{{- $name := required "lib-configuration.config-map template expects key '.name' in scope" .name}}
{{- $root := required "lib-configuration.config-map template expects key '.root' in scope" .root}}
{{- $values := required "lib-configuration.config-map template expects key '.values' in scope" .values}}
{{- $checksum := print .values | sha256sum}}
{{- $forceUpdateArgs := dict "root" $root "name" $name "kind" "ConfigMap" }}
apiVersion: v1
kind: ConfigMap

metadata:
  name: {{ $name }}
  namespace: {{ $root.Release.Namespace }}
  annotations:
    youwol.com/checksum: {{ $checksum}}
    {{- include "lib-utils.force-update" $forceUpdateArgs | indent 4}}

data:
  {{- $values | nindent 2}}

{{- end}}

{{- define  "lib-configuration.duplicate-config-map" }}
{{- $root := required "lib-configuration.duplicate-config-map template expects key '.root' in scope" .root}}
{{- $name := required "lib-configuration.duplicate-config-map template expects key '.name' in scope" .name}}
{{- $namespace := required "lib-configuration.duplicate-config-map template expects key '.namespace' in scope" .namespace}}
{{- $original := lookup "v1" "ConfigMap" $namespace $name }}
apiVersion: v1
kind: ConfigMap

metadata:
  name: {{ $name }}
  namespace: {{ $root.Release.Namespace }}
  annotations:
    youwol.com/duplicate-of: configmap/{{ $namespace }}.{{ $name }}
    {{- if hasKey $original.metadata.annotations "youwol.com/checksum" }}
    youwol.com/checksum: {{ get $original.metadata.annotations "youwol.com/checksum" }}
    {{- end}}
    {{- if hasKey $original.metadata.annotations "youwol.com/force-update-marker" }}
    youwol.com/force-update-marker: {{get $original.metadata.annotations "youwol.com/force-update-marker"}}
    {{- end}}
data:
  {{- $original.data | toYaml | nindent 2}}

{{- end}}
