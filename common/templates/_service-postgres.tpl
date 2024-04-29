{{- define "common.service.postgres" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}-postgres
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