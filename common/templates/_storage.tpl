{{- define "common.persistentVolumes" -}}
{{- if .Values.persistentVolumes.enabled }}
{{- range $keyId, $value := .Values.persistentVolumes.pvs }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $keyId }}
spec:
  capacity:
    storage: {{ $value.storageSize }}
  accessModes:
    - ReadWriteOnce
  local:
    path: {{ $value.path }}
  csi:
    driver: nfs.csi.k8s.io
    volumeAttributes:
      server: nfs-server.default.svc.cluster.local
      share: {{ $value.path }}
    volumeHandle: nfs-server.default.svc.cluster.local/share##
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
    - ReadWriteOnce
  {{- if $value.storageClassName }}
  storageClassName: ''
  {{- end }}
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
{{- end }}
{{- end }}
