{{- define "common.persistentVolumes" -}}
{{- if .Values.persistentVolumes.enabled }}
{{- range $keyId, $value := .Values.persistentVolumes.pvs }}
{{- if eq $value.storageClassName "" }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $keyId }}
spec:
  capacity:
    storage: {{ $value.storageSize }}
  accessModes:
    - {{ $value.accessModes | default "ReadWriteOnce" }}
  local:
    path: {{ $value.path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - {{ $value.nodeName | indent 16 }}
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