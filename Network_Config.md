# Setting up Kubernetes (possibly the hard way)

## Configure networking
Edit the netplan yaml file for a static IP
(as root)

`vi /etc/netplan/01-netcfg.yaml`

```
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      dhcp6: no
      addresses: [192.168.0.201/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
```

`netplan apply`

If you are running on Windows 10, edit your hosts file:

`C:\Windows\System32\drivers\etc\hosts`

# Microk8's
If RBAC is not enabled access the dashboard using the default token retrieved with:

token=$(microk8s.kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s.kubectl -n kube-system describe secret $token

In an RBAC enabled setup (microk8s.enable RBAC) you need to create a user with restricted
permissions as shown in:
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

root@mini1:~# microk8s.kubectl -n kube-system describe secret default-token-vcgwh
Name:         default-token-vcgwh
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 97313baa-6e09-4a35-893d-f4248dd0a872

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1103 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InhiRjh1czlHVl96QlktR3JUNVJqRG9XdHdGY2lLTHJkeWVRN2FHMTBBVGcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZWZhdWx0LXRva2VuLXZjZ3doIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImRlZmF1bHQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI5NzMxM2JhYS02ZTA5LTRhMzUtODkzZC1mNDI0OGRkMGE4NzIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06ZGVmYXVsdCJ9.m5Cu_odLqwlgyyWHpxBUCSaDd625MmYOFyBBv9pbbi4sYywFZNFPy-JjXdan8h_BjaM1kUq7A-5MDD7cPvBSOfkyk7IviLQY5MaBZBK5F9NPi_HmNfcWlWa_ZjBs4buu6X0rKAodn6Imr82R09Eumrdn2V4uc6gJl-2aGjp9haFubf9R6lXMYndfRiRfzkO6lQa1QCOTCOFZYybp0nAecj1kx81pEgpstfoO5W0g1cGJmm

# Run like docker
Normally, we would run mincraft (in a container) like this:
`docker run -d -it -e EULA=TRUE -p 25565:25565 --name mc itzg/minecraft-server`

So for kubernetes, we do:
`kubectl run --image=itzg/minecraft-server mc1 --port=25565 --env="EULA=TRUE"`

To do a deployment:
```bash
cat<<"EOF">./mc1-deployment.yaml
apiVersion: v1
kind: Service
metadata:
  name: minecraft
spec:
  type: NodePort
  selector:
    app: minecraft
  ports:
  - protocol: TCP
    port: 25565
    targetPort: 25565
    nodePort: 32565
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minecraft-deployment
  labels:
    app: minecraft
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minecraft
  template:
    metadata:
      labels:
        app: minecraft
    spec:
      containers:
      - name: minecraft
        image: itzg/minecraft-server:latest
        env:
        - name: EULA
          value: "TRUE"
        ports:
        - containerPort: 25565
EOF

```

And then create the deployment
`kubectl apply -f ./mc1-deployment.yaml`

and then expose the deployment...
`kubectl expose deployment mc1 --port 25565 --name=public-minecraft --external-ip=192.168.1.5`

Create the ingress:
```dotnetcli
apiVersion: networking.k8s.io/v1beta1 # for versions before 1.14 use extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: hello-world.info
    http:
      paths:
      - path: /
        backend:
          serviceName: public-minecraft
          servicePort: 25565
```


# Helm
```
sudo snap install --classic helm
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
helm search minecraft
```