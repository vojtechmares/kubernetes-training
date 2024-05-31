<p align="center">
  <h1 align="center">Kubernetes training</h1>
  <p align="center">Learn Kubernetes: from deploying your first application to deploying hundreds of microservices in no time.</p>
  <p align="center">
    <a href="https://kubernetes.io/"><img alt="GitLab" src="https://img.shields.io/badge/TRAINING ON-KUBERNETES-326CE5?style=for-the-badge"></a>
    <a href="https://www.vojtechmares.com/"><img alt="SikaLabs" src="https://img.shields.io/badge/TRAINING BY-VOJTĚCH MAREŠ-F59E0B?style=for-the-badge"></a>
  </p>
</p>

# About course

- [Slides](https://training.vojtechmares.com/kubernetes/slides/)

# About lector

Hi, my name is Vojtěch Mareš. I'm freelance DevOps engineer, consultant, and lector. For more, see my [website](https://vojtechmares.com/) or explore more [courses](https://vojtechmares.com/#skoleni).

Having questions? Contact me at email [`iam@vojtechmares.com`](mailto:iam@vojtechmares.com).

# Before we start

## Install tooling

- `kubectl`
- `helm`
- `kubectx` & `kubens`
- `k9s`
- Docker: Official installation guide

## Aliases

### `k`

For simplicity and our sanity, let's create an alias for `kubectl`.

#### Shell (bash, zsh,...)

```shell
# .bashrc / .zshrc / etc.
alias k="kubectl"
```

#### Windows (cmd.exe)

```cmd
doskey k=kubectl $*
```

#### Windows (PowerShell)

```powershell
Set-Alias -Name k -Value kubectl
```

# Course

## Cluster components

![Kubernetes components](/assets/components-of-kubernetes.svg)

### Control plane

Formerly master.

A node running components necessary to run the Kubernetes cluster.

- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager
- cloud-controller-manager (optional)

### Node

Formerly worker.

Machine running our workload (applications).

- kubelet
- kube-proxy
- container runtime (by default containerd)

## Explain Kubernetes resources

```shell
kubectl explain node
kubectl explain node.spec

kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers.image
```

## Nodes

```shell
kubectl get nodes

# or short form
kubectl get no
```

## kubectl

A command line tool to interact with the cluster.

### kubectl get

List resources of type.

```shell
kubectl get namespace
```

### kubectl describe

Describes resource including status, recent events and other information about it.

```shell
kubectl describe namespace default
```

### kubectl create

Creates new resource either in terminal or from file.

```shell
kubectl create namespace example-ns

# or from file
kubectl create -f ./example-ns.yaml
```

### kubectl delete

```shell
kubectl delete namespace example-ns

# or target resource from file
kubectl delete -f ./example-ns.yaml
```

### kubectl apply

Creates a resource if it does not exist or applies the configuration from file to an existing resource.

```shell
kubectl apply -f ./example-ns.yaml

# supports URL
kubectl apply -f https://raw.githubusercontent.com/vojtechmares/kubernetes-training/.../pod.yaml
```

## Pod

Smallest deployable unit in Kubernetes. Can be made from multiple containers, usually one is enough.

### List pods

```shell
kubectl get pods
```

### Describe pod

```shell
kubectl describe pod $POD_NAME
```

### Connect to pod

```shell
kubectl port-forward pod/$POD_NAME $LOCAL_PORT:$POD_PORT
```

### Open bash in pod

```shell
kubectl exec -it $POD_NAME -- bash
```

### Copy files from / to pod

```shell
# From local to pod
kubectl cp ./path/to/file $POD_NAME:/remote/path

# From pod to local
kubectl cp $POD_NAME:/remote/path ./local/path
```

### See pod logs

```shell
kubectl logs -f $POD_NAME
```

## Service

Service is a cluster abstraction a single in-cluster endpoint (DNS name and IP address) that distributes traffic to it's pods.

### Create service

```shell
kubectl create -f ./examples/02-service/service.yaml
```

### List services

```shell
kubectl get service
```

### Describe service

```shell
kubectl describe service example-svc
```

### Connect to service

```shell
kubectl port-forward service/example-svc 8080:8080
```

### Delete service

```shell
kubectl delete service example-svc
```

### Service `type=NodePort`

### Service `type=LoadBalancer`

## ReplicaSet

_ReplicasSet_ is a child resource to _Deployment_, which is used to keep track of revisions of pools of pods and allows to rollback to it if new revision of _Deployment_ is failing.

Today, ReplicaSet is usually not interacted with by users.

## Deployment

Deploying our application to _Pod_ might be easy, but not a good idea. To deploy our app to Kubernetes and run it, we use _Deployment_. It is a layer of abstraction on top of _Pods_ (and _ReplicaSet_).

### Updates

Kubernetes native:

- Recreate (deletes all pods and creates new ones)
- RollingUpdate (zero downtime)

Extended:

- Blue/Green
- Canary
- A/B testing

See: [Argo Rollouts](https://argoproj.github.io/rollouts/) or [Flagger](https://flagger.app/)

### Rolling update

## Ingress

_Ingress_ resource exposes our application network interface (HTTP, TCP,...) to public internet.

### Ingress controller

Kubernetes does not bring in an Ingress Controller by default and it is up to cluster administrator to choose and deploy one (or multiple).

### Gateway API

[Gateway API](https://gateway-api.sigs.k8s.io/) - a new standard for ingress traffic handling. Kubernetes extension made by SIG-Network. Only specification, implementation is up to users.

Implementations:

- [Contour](https://projectcontour.io/guides/gateway-api/)
-  [Cilium](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/concepts/gateway-api)
- [NGINX Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric)

## StatefulSet

A special abstraction for running _Pods_ running stateful applications like databases (for example MySQL or Redis) or message brokers like RabbitMQ and Apache Kafka.

### Headless service

## Job

## CronJob

## Persistent storage: Volumes

### PersistentVolume and PersistentVolumeClaim

### Access modes

### Storage classes

### Reclaim policy

## Configuration and secrets

### ConfigMap

### Secret

### Load environment variables from ConfigMap or Secret

### Mount ConfigMap or Secret as volume

## Kubeconfig

### Context

### Merge kubeconfig files

### kubectx

Easily switch between clusters.

```shell
kubectx demo
```

### kubens

Easily switch between namespaces.

```shell
kubens kube-system
```

## RBAC

RBAC = Role Based Access Control

### Impersonate ServiceAccount

```shell
kubectl auth can-i
```

## Resource consumption

> [!NOTE]
> Requires metrics server to be installed in the cluster.

```shell
kubectl top pods

# or

kubectl top nodes
```

## Startup, liveness, and readiness probes

### Startup probe

Wait for _Pod_ to start, useful when application start takes time, for example Java applications or machine learning models.

### Liveness probe

Is the program running? If not, restart the _Pod_.

### Readiness probe

Is the program ready to accept traffic? If not, do not send traffic to the _Pod_.

## Horizontal auto scaling

- Horizontal Pod Autoscaler

## Vertical auto scaling

## Cluster auto scaling

Dynamically add or remove nodes from the cluster based on resource consumption.

### Cluster Autoscaler

### Karpenter

Only on AWS.

## Pod Disruption Budget

### Pod evictions

## Helm

- [Website](https://helm.sh/)
- [Docs](https://helm.sh/docs/)

Helm is a package manager for Kubernetes.

### Helm chart

### Helm repository

Supports public and private repositories.

Can be hosted on GitHub, GitLab, AWS S3, Google Cloud Storage, Azure Blob Storage, and more.

### Helm install

Installs Helm chart to the cluster, creating Helm "release".

```shell
helm install my-release ./my-chart

# upgrade
helm upgrade my-release ./my-chart

# install and upgrade
helm install --upgrade my-release ./my-chart

# install from repository
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install my-release stable/mysql

# uninstall
helm uninstall my-release
```

### Helm rollback

```shell
helm rollback my-release 1
```

## Helm controller

On k3s or rke2 by default. Installs Helm release from Kubernetes Custom Resource.

- `HelmRelease`
- `HelmReleaseConfig`

## Kustomize

- [Website](https://kustomize.io/)
- [Docs](https://kubectl.docs.kubernetes.io/)

Kustomize is using overlays and hierachy-based merging of manifests unlike Helm, which is creating packages.

## GitOps

Static manifests, Helm charts, and Kustomize are stored in Git repository and are applied to the cluster from there on pull-based model. Usually a pro-active solution is hosted in the cluster.

- [ArgoCD](https://argoproj.github.io/argo-cd/)
- [Flux](https://fluxcd.io/)

## Kubernetes networking

### Network Policy

### CNI plugins

- [Flannel](https://github.com/flannel-io/flannel)
- [Calico](https://www.projectcalico.org/)
- [Cilium](https://cilium.io/)

## Pod Security Admission

### Pod Security Policy

- Removed in Kubernetes 1.25 (23 August, 2022)

## Metrics

All Kubernetes components are exposing metrics in Prometheus format.

### Prometheus

### Prometheus operator and kube-prometheus-stack helm chart

## Logging

### Elastic Cloud on Kubernetes (ECK)

### Grafana Loki

### Other

Cloud integrataions like AWS CloudWatch, Azure Monitor, Google Cloud Operations Suite.

- Fluentd
- Splunk
- DataDog

## Operators

Operators are extensions to Kubernetes that make use of custom resources to manage applications and their components.

For example, RedHat OpenShift (Kubernetes distribution by RedHat) is heavily utilizing operators.

### Operator Lifecycle Manager (OLM)

Operator to manage operators.

### Operator Framework

If you want to create your own operator, you can use [Operator SDK](https://github.com/operator-framework/operator-sdk).

## Links

- [Kubernetes documentation](https://kubernetes.io/docs/home/)
- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [ArtifactHub (helm charts)](https://artifacthub.io/)
- [OperatorHub](https://operatorhub.io/)

## Questions?

## Thank you, that's all 👋

### Vojtěch Mareš

- Email me at [iam@vojtechmares.com](mailto:iam@vojtechmares.com)
- Website: [vojtechmares.com](https://www.vojtechmares.com)
- My other trainings: [vojtechmares.com/#skoleni](https://www.vojtechmares.com/#skoleni)
- Twitter/X: [@vojtechmares](https://twitter.com/vojtechmares)
- GitHub: [github.com/vojtechmares](https://github.com/vojtechmares)
- LinkedIn: [linkedin.com/in/vojtech-mares](https://www.linkedin.com/in/vojtech-mares)
