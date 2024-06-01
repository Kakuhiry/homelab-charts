{{- define "common.longhornpvc" -}}
{{- if .Values.longhorn.enabled }}
{{- range $keyId, $value := .Values.longhorn.persistentVolumes }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $keyId }}-pvc
  namespace: {{ include "common.fullname" $ }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ $value.storageSize }}
  storageClassName: longhorn
{{- end }}
{{- end }}
{{- end }}
