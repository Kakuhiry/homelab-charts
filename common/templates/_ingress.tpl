{{- define "common.ingress" -}}
{{- if .Values.ingress.enabled -}}
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host("{{ include "common.fullname" . }}.gbklabs.com")
      services:
        - name: {{ default (include "common.fullname" .) .Values.service.name }}
          port: {{ .Values.service.port }}
{{- end }}
{{- end }}
