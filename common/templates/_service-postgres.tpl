{{- define "common.service.postgres" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}-postgres
  labels:
    {{ include "common.fullname" . }}-postgres
spec:
  type: ClusterIP
  ports:
    - port: 5432
  selector:
    app: {{ include "common.fullname" . }}-postgres
{{- end }}