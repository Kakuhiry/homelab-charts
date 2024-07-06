{{- define "common.persistentVolumes" -}}
{{- if .Values.persistentVolumes.enabled }}
{{- range $keyId, $value := .Values.persistentVolumes.pvs }}
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
  local:
    path: {{ $value.path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - {{ $value.nodeName | quote }}
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
  {{- else }}
  storageClassName: ""
  {{- end }}
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
{{- end }}
{{- end }}
