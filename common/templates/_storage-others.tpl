{{- define "common.others.persistentVolumes" -}}
{{- range $keyId, $key := .Values.others }}
{{- if $key.enabled }}
{{ include "common.persistentVolumes" $ }}
{{- end -}}
{{- end -}}
{{- end -}}
