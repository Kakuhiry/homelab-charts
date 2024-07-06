{{- define "common.csi" -}}
{{- if .Values.csi.enabled }}
{{- range $keyId, $value := .Values.csi.pvs }}
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
  csi:
    driver: nfs.csi.k8s.io
    volumeAttributes:
      server: nfs-server.default.svc.cluster.local
      share: {{ $value.path }}
    volumeHandle: {{ $keyId }}-handle
  mountOptions:
    - nfsvers=4.1
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
  {{- end }}
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
{{- end }}
{{- end }}
