{{- define "common.others.ingress" -}}
{{- range $keyId, $key := .Values.others }}
{{- if $key.ingress.enabled -}}
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: {{ $keyId }}
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host("{{ $keyId }}.gbklabs.com")
      services:
        - name: {{ $keyId }}
          port: {{ $key.service.port }}
{{- end }}
{{- end }}
{{- end}}