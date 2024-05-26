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
          {{- if $key.envFrom }}
          {{- with $key.envFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- if $key.env }}
          env:
            {{- range $envKey, $envValue := $key.env }}
            - name: {{ $envKey }}
              value: {{ $envValue | quote | toString }}
            {{- end }}
          {{- end }}
          ports:
            - name: http
              containerPort: {{ $key.service.targetPort | default 80 }}
              protocol: TCP
{{- end -}}
{{- end}}