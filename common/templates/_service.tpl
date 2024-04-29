{{- define "common.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort | default "http" }}
      protocol: TCP
      name: http
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end }}
---
{{- define "common.service.postgres" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  type: ClusterIP
  ports:
    - port: 5432
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
    kubernetes.app/name: {{ include "common.fullname" . }}-postgres
{{- end }}