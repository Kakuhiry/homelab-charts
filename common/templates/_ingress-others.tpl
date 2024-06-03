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
      match: Host("{{ $key.ingress.subDomain }}.gbklabs.com")
      services:
        - name: {{ $key.ingress.serviceName }}
          port: {{ $key.ingress.port }}
{{- end }}
{{- end }}
{{- end}}