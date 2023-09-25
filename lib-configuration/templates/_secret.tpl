{{- define "lib-configuration.secret"}}
{{- $root := required "lib-configuration.secret template expects key '.root' in scope" .root}}
{{- $name := required "lib-configuration.secret template expects key '.name' in scope" .name}}
{{- $keys := required "lib-configuration.secret template expects key '.keys' in scope" .keys}}
{{- $secretDataArgs := dict "root" $root "name" $name "keys" $keys }}
{{- $data := include "lib-configuration.secret-data" $secretDataArgs }}
{{- $forceUpdateArgs := dict "root" $root "kind" "Secret" "name" $name}}
apiVersion: v1
kind: Secret
type: Opaque

metadata:
  name: {{ $name }}
  namespace: {{ $root.Release.Namespace }}
  annotations:
    youwol.com/checksum: {{ $data | toYaml | sha256sum }}
    {{- include "lib-utils.force-update" $forceUpdateArgs | indent 4 }}

data:
  {{- $data | indent 2 }}
{{- end}}


{{- define "lib-configuration.secret-data" }}
{{- $root := required "lib-configuration.secret-entry template expects key '.root' in scope" .root }}
{{- $name := required "lib-configuration.secret template expects key '.name' in scope" .name }}
{{- $keys := required "lib-configuration.secret template expects key '.keys' in scope" .keys }}
{{- range .keys}}
{{- include "lib-configuration.secret-data-item" (dict "root" $root "name" $name "key" .) | nindent 2}}
{{- end}}
{{- end}}

{{- define "lib-configuration.secret-data-item" }}
{{- $root := required "lib-configuration.secret-entry template expects key '.root' in scope" .root}}
{{- $name := required "lib-configuration.secret template expects key '.name' in scope" .name}}
{{- $key := required "lib-configuration.secret-entry template expects key '.key' in scope" .key}}
{{- $existingObject := (lookup "v1" "Secret" $root.Release.Namespace $name | default (dict))}}
{{- $existingValue := get (get $existingObject "data" | default (dict)) $key }}
{{- $overrideValue := "" }}
{{- if $root.Values.overrideSecrets }}
{{- $overrideValue = get (get $root.Values.overrideSecrets $name | default (dict)) $key | b64enc }}
{{- end }}
{{- $key }}: {{ $overrideValue | default $existingValue | default (randAlphaNum 32 | b64enc ) | quote }}
{{- end}}

{{- define  "lib-configuration.duplicate-secret" }}
{{- $root := required "lib-configuration.duplicate-secret template expects key '.root' in scope" .root}}
{{- $name := required "lib-configuration.duplicate-secret template expects key '.name' in scope" .name}}
{{- $namespace := required "lib-configuration.duplicate-secret template expects key '.namespace' in scope" .namespace}}
{{- $original := lookup "v1" "Secret" $namespace $name }}
apiVersion: v1
kind: Secret

metadata:
  name: {{ $name }}
  namespace: {{ $root.Release.Namespace }}
  annotations:
    youwol.com/duplicate-of: secret/{{ $namespace }}.{{ $name }}
    {{- if and ($original.metadata.annotations) (hasKey $original.metadata.annotations "youwol.com/checksum") }}
    youwol.com/checksum: {{ get $original.metadata.annotations "youwol.com/checksum" }}
    {{- end}}
    {{- if and ($original.metadata.annotations) (hasKey $original.metadata.annotations "youwol.com/force-update-marker") }}
    youwol.com/force-update-marker: {{get $original.metadata.annotations "youwol.com/force-update-marker"}}
    {{- end }}
data:
  {{- $original.data | toYaml | nindent 2}}

{{- end}}
