{{- define "common.others.deployment" -}}
{{- range $keyId, $key := .Values.others }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $keyId }}
  labels:
    app: {{ $keyId }}
spec:
  replicas: {{ $key.replicaCount | default 1 }}
  selector:
    matchLabels:
      app: {{ $keyId }}
  template:
    metadata:
      labels:
        app: {{ $keyId }}
    spec:
      containers:
        - name: {{ $keyId }}
          image: "{{ $key.image.repository }}:{{ $key.image.tag }}"
          ports:
            - name: http
              containerPort: {{ $key.service.targetPort | default 80 }}
              protocol: TCP
{{- end -}}
{{- end}}