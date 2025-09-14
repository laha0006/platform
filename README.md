## Steps

### Install k3s

```bash
curl -sfL https://get.k3s.io | sh -
```

##### give read perm to k3s config:

```bash
sudo chown root:ubuntu /etc/rancher/k3s/k3s.yaml
sudo chmod 640 /etc/rancher/k3s/k3s.yaml
```

##### export KUBECONFIG env variable

add to relevant shell config file (.bashrc, .zshrc)

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### install helm

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### install jenkins

add jenkins helm repo

```bash
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
```

create jenkins namespace

```bash
kubectl create namespace jenkins
```

helm install

```bash
helm install jenkins -n jenkins jenkinsci/jenkins
```

### cert manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager \
  -n cert-manager \
  --set crds.enabled=true
```

### Harbor container registry

```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
```
