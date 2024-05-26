{{- define "common.others.service" -}}
{{- range $keyId, $key := .Values.others }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $keyId }}
  labels:
    app: {{ $keyId }}
spec:
  type: {{ $key.service.type }}
  ports:
    - port: {{ $key.service.port }}
      targetPort: {{ $key.service.targetPort | default "http" }}
      protocol: TCP
      name: http
  selector:
    app: {{ $keyId }}
{{- end -}}
{{- end }}
