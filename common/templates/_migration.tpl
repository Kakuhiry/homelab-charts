{{- define "common.migration" }}
{{- if .Values.migration.enabled }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: volume-migration
spec:
  completions: 1
  parallelism: 1
  backoffLimit: 3
  template:
    metadata:
      name: volume-migration
      labels:
        name: volume-migration
    spec:
      restartPolicy: Never
      containers:
        - name: volume-migration
          image: ubuntu:xenial
          tty: true
          command: [ "/bin/sh" ]
          args: [ "-c", "cp -r -v /mnt/old/. /mnt/new" ]
          volumeMounts:
            - name: old-vol
              mountPath: /mnt/old
            - name: new-vol
              mountPath: /mnt/new
      volumes:
        - name: old-vol
          persistentVolumeClaim:
            claimName: {{ .Values.migration.old-vol }}
        - name: new-vol
          persistentVolumeClaim:
            claimName: {{ .Values.migration.new-vol }}
{{- end }}
{{- end }}