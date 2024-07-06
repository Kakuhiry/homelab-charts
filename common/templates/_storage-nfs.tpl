{{- define "common.nfs" -}}
{{- if .Values.nfs.enabled }}
{{- range $keyId, $value := .Values.nfs.pvs }}
{{- $accessModes := default "ReadWriteOnce" $value.accessModes }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $keyId }}
spec:
  capacity:
    storage: {{ $value.storageSize }}
  accessModes:
    - {{ $accessModes }}
  mountOptions:
    - hard
    - timeo=600
    - nfsvers=4.1
  nfs:
    server: 10.0.0.23 # IP to our NFS server
    path: {{ $value.path }}
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" $ }}
    name: {{ $keyId }}-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $keyId }}-pvc
  namespace: {{ include "common.fullname" $ }}
spec:
  accessModes:
    - {{ $accessModes }}
  {{- if eq $value.storageClassName "" }}
  storageClassName: ""
  {{- else}}
  storageClassName: {{ $value.storageClassName }}
  {{- end}}
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
{{- end }}
{{- end }}
