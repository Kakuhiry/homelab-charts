{{- if .Values.persistentVolumes.enabled }}
{{- if .Values.persistentVolumes.config.enabled }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include "common.fullname" . }}-config
spec:
  capacity:
    storage: {{ .Values.persistentVolumes.storageSize }}
  accessModes:
    - ReadWriteMany
  local:
    path: {{ .Values.persistentVolumes.config.path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - {{- .Values.persistentVolumes.config.nodeName }}
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" . }}
    name: {{ include "common.fullname" . }}-config-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" . }}-config-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ .Values.persistentVolumes.config.storageSize }}
{{- end}}
{{- if .Values.persistentVolumes.data.enabled }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include "common.fullname" . }}-data
spec:
  capacity:
    storage: {{ .Values.persistentVolumes.data.storageSize }}
  accessModes:
    - ReadWriteMany
  local:
    path: {{ .Values.persistentVolumes.data.path }}
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - {{ .Values.persistentVolumes.data.nodeName }}
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: {{ include "common.fullname" . }}
    name: {{ include "common.fullname" . }}-data-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" . }}-data-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ .Values.persistentVolumes.data.storageSize }}
{{ end }}
{{ end }}
