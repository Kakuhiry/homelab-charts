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
    gethomepage.dev/enabled: "true"
    gethomepage.dev/name: "{{ include "common.fullname" . }}"
    gethomepage.dev/group: "Apps"
    gethomepage.dev/href: "{{ include "common.fullname" . }}.gbklabs.com"
    gethomepage.dev/icon: "{{ include "common.fullname" . }}.svg"
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
