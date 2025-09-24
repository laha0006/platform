## Instructions

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

```bash
kubectl create namespace harbor
helm upgrade --install harbor harbor/harbor \
  -n harbor \
  -f harbor-values.yaml \
  --create-namespace
```

##### create robot account and harbor credentials in k8s

-   create a robot account for the project in harbor.
-   create secret harbor credentials in k8s.

```bash
kubectl create secret docker-registry harbor-cred \
  --docker-server=cr.domain.dev \
  --docker-username='robot$tools+jenkins' \
  --docker-password='xxxxxxxxxxxxxx' \
  --docker-email='noreply@example.com' \
  -n jenkins
```

-   in jenkins set pullImageSecret to 'harbor-cred'

### Kafka strimzi.io

-   create namespace for kafka

```bash
kubectl create namespace kafka
```

-   install strimzi (CRD definitions, and operators)

```bash
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

```

-   create single node cluster

```bash
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-single-node.yaml -n kafka

```

in-cluster boostrap

```
my-cluster-kafka-boostrap.kafka:9092
```

### CloudNativePG

Offers postgres operators, and CRD for manging clusters of postgres databases.
Very powerful.

-   install cnpg operator and crds

```bash
kubectl apply --server-side -f \
 https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.0.yaml
```

-   check deployment

```bash
kubectl rollout status deployment \
 -n cnpg-system cnpg-controller-manager
```

##### create postgres cluster

```yaml
kind: Cluster
metadata:
    name: cluster-example
spec:
    instances: 3

    storage:
        size: 1Gi
```

-   apply the cluster CRD (optionally add a -n namespace)

```bash
kubectl apply -f 'https://cloudnative-pg.io/documentation/current/samples/cluster-example.yaml'

```

##### connecting to the database

the cluster exposes 3 services
which is the prefered way to connect.

```bash
cluster-name-r
cluster-name-ro
cluster-name-rw
```

-   example dns (can omit namespace if the cluster is on the same namespace as the application trying to connect.)

```bash
<cluster-name>-r.<namespace>
<cluster-name>-ro.<namespace>
<cluster-name>-rw.<namespace>
```

-   cnpg creates two basic auth secrets

```bash
<cluster-name>-superuser
<cluster-name>-app
```

these secrets contains username, password and other info that is useful/needed for connecting.

-   example usage

```yaml
- name: DB_USER
  valueFrom:
      secretKeyRef:
          name: cluster-example-app
          key: username
- name: DB_DATABASE
  value: app
- name: DB_PASS
  valueFrom:
      secretKeyRef:
          name: cluster-example-app
          key: password
```

### ArgoCD

-   Install argocd

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

##### SSL passthrough with traefik

the example config from the docs uses nginx, the equaivalent setup using taefik is a bit different.

create a certificate, managed by cert-manager.

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
    name: argocd-server-cert
    namespace: argocd
spec:
    secretName: argocd-server-tls
    issuerRef:
        kind: ClusterIssuer
        name: letsencrypt-production
    dnsNames:
        - argocd.larsfriis.dev
```

-   create a traefik CRD ingresRouteTCP, with SSL passthrough.

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRouteTCP
metadata:
    name: argocd-passthrough
    namespace: argocd
spec:
    entryPoints:
        - websecure
    routes:
        - match: HostSNI(`argocd.larsfriis.dev`)
          services:
              - name: argocd-server
                port: 443
    tls:
        passthrough: true
```

### Loki

-   add helm repo grafana

```bash
helm repo add grafana https://grafana.github.io/helm-charts
```

-   install loki using loki-values.yaml

```bash
helm upgrade --install loki grafana/loki -n monitoring -f values.yaml
```

### promethous && grafana

-   add helm repo prometheus-community

```bash
helm repo add prometheus https://prometheus-community.github.io/helm-charts
```

-   install with custom yaml

```bash
helm upgrade --install prometheus promethus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

### log collection with grafana alloy

```bash
kubectl create configmap --namespace monitoring alloy-config "--from-file=alloy.config=./alloy.config"
```

```bash
helm upgrade --install alloy grafana/alloy -n monitoring -f values.yaml
```
