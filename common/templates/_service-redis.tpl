{{- define "common.service.redis" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}-redis
  labels:
    app: {{ include "common.fullname" . }}-redis
spec:
  type: ClusterIP
  ports:
    - port: 6379
  selector:
    app: {{ include "common.fullname" . }}-redis
{{- end }}