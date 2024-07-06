{{- define "common.csi" -}}
{{- if .Values.csi.enabled }}
{{- range $keyId, $value := .Values.csi.pvs }}
{{- if eq $value.storageClassName "" }}
{{- $accessModes := default "ReadWriteOnce" $value.accessModes }}
{{- if eq $value.storageClassName "local-path" }}
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
    volumeHandle: nfs-server.default.svc.cluster.local/share##
  mountOptions:
    - nfsvers=4.1
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" $ }}
    name: {{ $keyId }}-pvc
{{- else }}
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
    volumeHandle: nfs-server.default.svc.cluster.local/share##
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" $ }}
    name: {{ $keyId }}-pvc
{{- end }}
{{- end }}

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $keyId }}-pvc
  namespace: {{ include "common.fullname" $ }}
spec:
  accessModes:
    - {{ $value.accessModes | default "ReadWriteOnce" }}
  {{- if $value.storageClassName }}
  storageClassName: {{ $value.storageClassName }}
  {{- end }}
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
{{- end }}
{{- end }}
