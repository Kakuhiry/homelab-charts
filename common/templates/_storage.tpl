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
    - ReadWriteMany
  local:
    path: {{ $value.path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - {{- $value.nodeName }}
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" . }}
    name: {{ include "common.fullname" . }}-pvc

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" . }}-pvc
  namespace: {{ include "common.fullname" . }}
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ $value.storageSize }}
{{- end }}
