{{- define "common.persistentVolumes" -}}
{{- if .Values.persistentVolumes.enabled }}
{{- range $keyId, $value := .Values.persistentVolumes.pvs }}
{{- $accessModes := default "ReadWriteOnce" $value.accessModes }}
{{- if and (or (eq $value.storageClassName "") (eq $value.storageClassName "local-path")) (not (eq $value.storageClassName "longhorn")) }}
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
  {{- if eq $value.storageClassName "local-path" }}
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
  {{- else if ne $value.storageClassName "" }}
  csi:
    driver: nfs.csi.k8s.io
    volumeAttributes:
      server: nfs-server.default.svc.cluster.local
      share: {{ $value.path }}
    volumeHandle: nfs-server.default.svc.cluster.local/share##
  {{- end }}
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" $ }}
    name: {{ $keyId }}-pvc
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
  {{- if and $value.storageClassName (not (eq $value.storageClassName "longhorn")) }}
  storageClassName: {{ $value.storageClassName }}
  {{- end }}
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
{{- end }}
{{- end }}
