{{- define "common.ingress" -}}
{{- if .Values.ingress.enabled -}}
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  annotations:
    gethomepage.dev/enabled: "true"
    gethomepage.dev/name: "{{ include "common.fullname" . }}"
    gethomepage.dev/group: "{{ .Values.ingress.group | default "Apps" }}"
    gethomepage.dev/href: "https://{{ .Values.ingress.href | default (include "common.fullname" .) }}.gbklabs.com"
    gethomepage.dev/icon: "{{- if .Values.ingress.annotations "gethomepage.dev/icon" }}{{ .Values.ingress.annotations["gethomepage.dev/icon"] }}{{ else }}{{ default (include "common.fullname" .) .Values.ingress.icon }}.svg{{- end }}"
    {{- with .Values.ingress.annotations }}
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
