`kubernetes: v1.25.3` `minicube: v1.28.0` `helm: v3.10.2` `chaos-mesh: v2.5.1`

<!-- TOC -->

- [About the project.](#about-the-project)
- [Before running the project.](#before-running-the-project)
- [Run the project.](#run-the-project)
- [(Optional) Enable permission authentication to run chaos experiments by Chaos Dashboard instead.](#optional-enable-permission-authentication-to-run-chaos-experiments-by-chaos-dashboard-instead)
- [Uninstall](#uninstall)

<!-- /TOC -->

# About the project.
- Use Chaos-Mesh to implement chaos engineering.

# Before running the project.

- [Start minikube with Calico CNI Manifest.](https://projectcalico.docs.tigera.io/getting-started/kubernetes/minikube)
```bash
minikube start --network-plugin=cni
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico.yaml
```

- Enable addons.
```bash
minikube addons enable ingress # ingress
minikube addons enable metrics-server # hpa
```

# Run the project.
1. [Helm install chaos-mesh.](https://chaos-mesh.org/docs/production-installation-using-helm/)
```bash
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm search repo chaos-mesh
kubectl create ns chaos-mesh
```

- Customize your `values.yaml` and install.
- If you want to disable permission authentication on the dashboard you can set `securityMode` as `false`.
```bash
helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.5.1 -f values.yaml

# Check
kubectl get po -n chaos-mesh
```

2. Create an experimental namespace and change the current namespace.
```bash
kubectl create ns docker-cats
kubens docker-cats
```

3. [Add annotations to namespaces for Chaos experiments.](https://chaos-mesh.org/docs/configure-enabled-namespace/#add-annotations-to-namespaces-for-chaos-experiments)
    - [You can also define the experiment scope in a YAML configuration file or on the Chaos Dashboard.](https://chaos-mesh.org/docs/define-chaos-experiment-scope/)
```bash
# Add the annotation to namespaces to define the scope for chaos experiments
kubectl annotate ns docker-cats chaos-mesh.org/inject=enabled

# Check all namespaces where Chaos experiments take effect
kubectl get ns -o jsonpath='{.items[?(@.metadata.annotations.chaos-mesh\.org/inject=="enabled")].metadata.name}'
```

4. Apply all the `.yaml`.
```bash
kubectl apply -k k8s/
```

5. Direct the ingress domain name to localhost in order to test ingress.
```bash
# You can also modify your `/etc/hosts` by `sudo vim`
sudo -- sh -c 'echo "127.0.0.1 baby.com" >> /etc/hosts'
sudo -- sh -c 'echo "127.0.0.1 green.com" >> /etc/hosts'
sudo -- sh -c 'echo "127.0.0.1 dark.com" >> /etc/hosts'
```

7. Run `minikube tunnel` to enable http and https ports.
```bash
# The service/ingress docker-cats-ingress requires privileged ports to be exposed: [80 443]
minikube tunnel
```

8. Open your browser and paste the following URL.
```bash
http://baby.com/
http://green.com/
http://dark.com/
```

9. Apply experiments.
```bash
kubectl apply -f experiment/<experiment name>
```
- Check the experiment's status and events:
```bash
# Get all the experiments of a specific type
kubectl get <chaos type>

# Show the status and events of the pod
kubectl describe <chaos type> <pod name>
```

# (Optional) Enable permission authentication to run chaos experiments by Chaos Dashboard instead.
1. Forward dashboard service
- Open a new terminal and forward port then access [localhost:2333](http://localhost:2333/).
```bash
kubectl port-forward service/chaos-dashboard --address='0.0.0.0' -n chaos-mesh 2333:2333
```

2. [Manage RBAC user permissons](https://chaos-mesh.org/docs/manage-user-permissions/)
- Apply manager account.
```bash
kubectl apply -f rbac.yaml
```

- Copy the token data in the following output and use it for the next step to log in.
```bash
kubectl create token account-cluster-manager-dkapu -n default
```

3. Run experiments or check results by dashboard UI.

# [Uninstall](https://chaos-mesh.org/docs/uninstallation/)
```bash
# Clean Up Chaos Experiments
for i in $(kubectl api-resources | grep chaos-mesh | awk '{print $1}'); do kubectl get $i -A; done

# Uninstall chaos mesh
helm uninstall chaos-mesh -n chaos-mesh

# Remove CRDs
kubectl delete crd $(kubectl get crd | grep 'chaos-mesh.org' | awk '{print $1}')

# Delete the annotation
kubectl annotate ns docker-cats chaos-mesh.org/inject-

# Delete namespace
kubectl delete ns chaos-mesh
kubectl delete ns docker-cats

# Delete the setting in `/etc/hosts`
sudo sed -i '' '/127.0.0.1 baby.com/d' /etc/hosts
sudo sed -i '' '/127.0.0.1 green.com/d' /etc/hosts
sudo sed -i '' '/127.0.0.1 dark.com/d' /etc/hosts

# Delete all the services
kubectl delete -k experiment/
kubectl delete -k k8s/
```
