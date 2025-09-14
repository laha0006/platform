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

##### cert issuer manifest/yaml




### jenkins output
NAME: jenkins
LAST DEPLOYED: Sun Sep 14 14:06:47 2025
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  echo http://127.0.0.1:8080
  kubectl --namespace jenkins port-forward svc/jenkins 8080:8080

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://127.0.0.1:8080/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins

 echo http://127.0.0.1:8080


 vFuB0rL0UeYRcZyn8f9ht9