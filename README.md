# Homelab Cluster

K3s homelab configuration

## 💻 Hardware

| Device               | Count | RAM    | Disks                                                   | OS             | Arch  |
|----------------------|-------|--------|---------------------------------------------------------|----------------|-------|
| Lenovo ThinkCentre M700 | 1     | 16GB   | SSD 256GB | Ubuntu 22.04.4 LTS  | amd64 |
| Raspberry Pi 4 | 1     | 8GB | MicroSD 128GB                                                 | Raspberry PI OS Lite        | amd64 |
| Network Attached Storage (NAS)         | 1     | N/A | HDD 4TB (X2)                                               | Ubuntu 22.10        | amd64 |

## 📁 Repository structure

```sh
📁 charts      # K8s applications defined as helm charts 
├─📁 common    # Base definintion of resource helm templates with needed templateing to be multipurposed
  └─📃_deployment.yaml
  └─📃_service.yaml
  └─📃_ingress.yaml
  └─📃_storage.yaml
└─📁 {apps}...  # Apps that make use of the common helm template 
  └─📃values.yaml # Defines the app values
  
```
