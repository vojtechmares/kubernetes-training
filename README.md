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

## `kubectl`

A command line tool to interact with the cluster.

### `kubectl get`

List resources of type.

```shell
kubectl get namespace
```

### `kubectl describe`

Describes resource including status, recent events and other information about it.

```shell
kubectl describe namespace default
```

### `kubectl create`

Creates new resource either in terminal or from file.

```shell
kubectl create namespace example-ns

# or from file
kubectl create -f ./example-ns.yaml
```

### `kubectl delete`

```shell
kubectl delete namespace example-ns

# or target resource from file
kubectl delete -f ./example-ns.yaml
```

### `kubectl apply`

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

## Deployment

Deploying our application to *Pod* might be easy, but not a good idea. To deploy our app to Kubernetes and run it, we use *Deployment*. It is a layer of abstraction on top of *Pods* (and *ReplicaSet*).

### ReplicaSet

*ReplicasSet* is a child resource to *Deployment*, which is used to keep track of revisions of pools of pods and allows to rollback to it if new revision of *Deployment* is failing.

Today, ReplicaSet is usually not interacted with by users.

### Updates

Kubernetes native:

- Recreate (deletes all pods and creates new ones)
- RollingUpdate (zero downtime)

The *Recreate* strategy works pretty much as you expect: deletes all running *Pods* and then creates new ones.

On the other hand, *Rolling Update* has a few configuration options, see example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0
```

Extended:

- Blue/Green
- Canary
- A/B testing

See: [Argo Rollouts](https://argoproj.github.io/rollouts/) or [Flagger](https://flagger.app/)

## Ingress

*Ingress* resource exposes our application network interface (HTTP, TCP,...) to public internet.

### Ingress Controller

Kubernetes does not bring in an *Ingress Controller* by default and it is up to cluster administrator to choose and deploy one (or multiple).

Kubernetes project offers [Ingress NGINX](https://kubernetes.github.io/ingress-nginx/).

### Ingress resource

*Ingress* is a Kubernetes resource that exposes *Service* outside the cluster. The resource is managed by *Ingress Controller*

### Ingress Class

*IngressClass* is Kubernetes abstraction to map *Ingress* resources to given *Ingress Controller*, like [Ingress NGINX](https://kubernetes.github.io/ingress-nginx/).

*IngressClass* is often managed for you by the installer (like Helm) of *Ingress Controller* or the controller itself.

### Gateway API

[Gateway API](https://gateway-api.sigs.k8s.io/) - a new standard for ingress traffic handling. Kubernetes extension made by SIG-Network. Only specification, implementation is up to users.

Generally Available implementations:

- [Contour](https://projectcontour.io/guides/gateway-api/)
- [Cilium](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
- [Envoy Gateway](https://github.com/envoyproxy/gateway)
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/concepts/gateway-api)
- [NGINX Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric)

## StatefulSet

A special abstraction for running *Pods* running stateful applications like databases (for example MySQL or Redis) or message brokers like RabbitMQ and Apache Kafka.

StatefulSet also needs a "headless service", which is defined in it's spec.

### Headless service

A service with `type=ClusterIP` and `clusterIP=None` configuration.

Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-headless-service
  labels:
    app: my-app
spec:
  # type: ClusterIP # default
  clusterIP: None
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

That creates a service without a Virtual IP for load balancing and instead DNS will return all IPs of *Pods*.

That is important for many reasons. This allows you to distinguish between running *Pods* (in another words preserving network identity of a process). Or to do client-side load balancing.

Why would we want to know to which *Pod* are we talking to? For example with databases, we want to connect to primary instance for writes, but reads are fine from replicas.

And as for the case of client side load balancing. This eliminates the need of a dedicated load balancer such as HA Proxy. Making it cheaper to operate and allows clients more granular control over to which backends it connects to. For example in microservices, you want your clients to connect to multiple backends, but each client should connect to a subset of all backends available to increase resiliency.

## Job

*Deployment* and *StatefulSet* manage *Pods* that run indefinitely (not counting restarts or crashes).

For one-time workload or just anything that does not need to run 24/7, *Job* is the right resource.

Example:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: my-job
spec:
  template:
    spec:
      containers:
      - name: my-job-container
        image: my-job-image
        command: ["bash", "-c", "echo Hello from the Kubernetes cluster"]
      restartPolicy: Never
  backoffLimit: 4
```

### CronJob

*CronJobs* allows for periodic scheduling of *Jobs* at given schedule ([cron expression](https://crontab.guru/)).

*CronJob* embeds a `jobTemplate` in it's `spec`. Which is just a *Job* manifest without `metadata`. Therefore you can use it with a template engine like Helm, if you need to.

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: my-cron-job
spec:
  schedule: "*/1 * * * *"
  timeZone: Etc/UTC # Kubernetes 1.27+
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: my-cron-job-container
            image: my-cron-job-image
            command: ["bash", "-c", "echo Hello from the Kubernetes cluster"]
          restartPolicy: OnFailure
```

## Configuration and secrets

Contents of either *ConfigMap* or *Secret* are key-value pairs.

Since it's YAML, you can use even multiline strings with `|`.

Typically, keys are names of environment variables or file names.

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config-env
data:
  myKey: myValue
  anotherKey: anotherValue
```

Or with values as a config file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config-file
data:
  config.ini: |
    [DEFAULT]
    SomeKey = someValue
```

### Secret

If you want YAML secret in readable form, use `stringData`.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-apps-db
type: Opaque
stringData:
  DATABASE_URL: mysql://wordpress:wppass@mysql.example.com:3306/wordpress
```

Otherwise, if you use `data` (default), values are **base64** encoded.

> [!NOTE]
> Secrets are not actually encrypted, but only **base64** encoded!
> Therefore secrets are not actual secrets in security-sense, but the resource-level distinction allows RBAC for fine-gained access for applications and cluster administrator, application developers, and others.

### Load environment variables from ConfigMap or Secret

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
spec:
  containers:
  - name: app
    image: my-app-image
    envFrom:
    - configMapRef:
        name: my-config-env
    - secretRef:
        name: my-apps-db
```

### Mount ConfigMap or Secret as volume

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-url-secret
  namespace: my-app
stringData:
  database.ini: |
    url = mysql://wordpress:wpapss@mysql.example.com:3306/wordpress
---
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
  namespace: my-app
spec:
  containers:
  - name: app
    image: my-app-image
    volumeMounts:
    - name: database-url-vol
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: database-url-vol
    secret:
      secretName: database-url-secret
```

The application can then read the file `/etc/secrets/database.ini`.

> [!TIP]
> It is recommended to mount secrets to containers as volume mounts rather than using environment variables,
> since environment variables are sometimes included in error dumps (for example Sentry is doing that).
> And that would lead to secret exposure.

## Persistent data storage

### PersistentVolume and PersistentVolumeClaim

*PersistentVolume* is a Kubernetes resource representing an actual volume.

*PersistentVolumeClaim* is a Kubernetes resource, marking a *PersistentVolume* claimed for given workload (*Pod*). Not allowing anyone else claim the volume.

### Access modes

- `ReadWriteOnce` (RWO)
- `ReadWriteMany` (RWX)
- `ReadOnlyMany` (ROX)
- `ReadWriteOncePod` (RWOP), Kubernetes 1.29+

### Storage classes

Storage class represents a storage backend, connected to Kubernetes with a *CSI Driver*.

At *StorageClass* you define if you allow for volume size expansion.

*Volume binding mode* describes when a volume should be created when using dynamic provisioning. *Volume binding modes* are:

- *Immediate* is the default, creates volume as soon as *PersistentVolumeClaim* resource is created, which can lead to provisioning issues like volume being created in wrong *Available Zone*
- *WaitForFirstConsumer* solves issues of *Immediate* and delays volume provisioning until a *Pod* is created

```shell
$ kubectl get storageclass
NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
longhorn (default)   driver.longhorn.io   Delete          Immediate           true                   92d
```

### Reclaim policy

- Retain - volume is kept even after requesting resource (such as *StatefulSet*) is deleted, preventing data loss. It's up to cluster administrator to delete the volume.
- Delete - volume is automatically deleted
- Recycle (`rm -rf /mnt/volume/*`). On Kubernetes 1.30 only available for `nfs` and `hostPath` volume types.

### Temporary storage

Not persisted between *Pod* deletions, but persisted between *Pod* restarts.

Volume with type `emptyDir`.

### Local storage

- `local-storage` storage class
- `hostPath`

### CSI plugins

Kubernetes on it's own only implements APIs to support container storage, the implementation itself is left for vendors.

This brings the Container Storage Interface API. Allowing cluster administrators to install only what you need for your workload, if you need any.

The implementation is called a *Driver*, which is responsible for dynamically provisioning volumes, mounting them to nodes and setting up file system. Driver is typically

CSI drivers for on-premise:

- [Longhorn](https://longhorn.io/)
- [Ceph](https://github.com/ceph/ceph-csi) (if you are running Ceph)
- [NFS](https://github.com/kubernetes-csi/csi-driver-nfs)
- [vSphere](https://github.com/kubernetes-sigs/vsphere-csi-driver)

CSI drivers for cloud:

- [AWS EBS](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [AWS EFS](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html) (NFS)
- [GCE PD](https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver) (Google Compute Engine Persistent Disk)
- [List of Azure CSIs](https://learn.microsoft.com/en-us/azure/aks/csi-storage-drivers)
- [DigitalOcean](https://github.com/digitalocean/csi-digitalocean)
- [Hetzner Cloud](https://github.com/hetznercloud/csi-driver)

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

Wait for *Pod* to start, useful when application start takes time, for example Java applications or machine learning models.

### Liveness probe

Is the program running? If not, restart the *Pod*.

### Readiness probe

Is the program ready to accept traffic? If not, do not send traffic to the *Pod*.

### Best practices

- liveness probe is not dependent on external dependencies (database, cache, downstream services,...)
- different liveness and readiness probes
- readiness probe should stop being ready as soon as possible after receiving `SIGTERM` signal, allowing service to gracefully shutdown

## Pod autoscaling

One of great Kubernetes strengths is Kubernetes capability of scaling workload up and down.

### Horizontal Pod Autoscaler

Changing the number of *Pods* running to handle the incoming requests efficiently.

### Vertical Pod Autoscaler

Unlike *HPA*, *VerticalPodAutoscaler* does not come with Kubernetes by default, but it's a separate project [on GitHub](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) that you need to install yourself.

Changing the requested amount resources on *Pods*.

> [!NOTE]
> This will invoke a *Pod* restart to apply the new configuration.

### KEDA

[KEDA (Kubernetes Event-Driven Autoscaler)](https://keda.sh/) is custom controller allowing for scaling *Pods* on different criteria/triggers than just plain Kubernetes.

KEDA offers many "scalers", that allows to trigger a scale up or down of *Pods*. You can scale both *Deployments* or *Jobs*.

## Cluster autoscaling

Second available option, which goes hand-in-hand with automatically scaling *Pods*, to efficiently utilize the cluster. So we do not need to provision number of *Nodes* to cover maximum number of *Pods* during peak times.

### Cluster Autoscaler

Dynamically add or remove nodes from the cluster based on resource consumption. Aka how many nodes do we need to efficiently schedule all *Pods*.

### Karpenter

A cluster autoscaler made by AWS, to achieve higher efficiency and reduce the time from determining that the cluster needs more nodes to actually nodes becoming ready within the cluster.

## Pod Disruption Budget

When we are running multiple *Pods* across multiple *Nodes*, we want to determine some minimum required amount of *Pods*, that make service still available without failing.

For example, when we are scaling down the cluster and *Pods* are being reshuffled across nodes, not all *Pods* may be available. *Pod Disruption Budget* says how many *Pods* can be not ready, but our service is still functioning, perhaps with increased latency.

### Pod evictions

- Preemption evictions
  - Scheduling a *Pod* with higher *Priority Class*
- Node pressure evictions
  - Node drain
  - Scheduling a *Pod* with higher *Quality of Service*
  - API initiated (for example: deleting *Pod* via kubectl)
  - Taint-based

## Helm

- [Website](https://helm.sh/)
- [Docs](https://helm.sh/docs/)

Helm is a package manager for Kubernetes.

### Helm Chart

A package of all manifest for an application. Containing everything, that you need to run the application. Chart can also determine a minimal Kubernetes version it supports, that is especially important when supporting multiple Kubernetes versions and you make breaking changes in the Chart.

### Helm Repository

Supports public and private repositories.

Can be hosted on GitHub, GitLab, AWS S3, Google Cloud Storage, Azure Blob Storage, and more.

### `helm install`

Installs Helm chart to the cluster, creating Helm "release".

```shell
helm install my-release ./my-chart

# upgrade
helm upgrade my-release ./my-chart

# install and upgrade
helm upgrade --install my-release ./my-chart

# install from repository
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install my-release stable/mysql

# install from oci repository
helm install my-release oci://registry.example.com/some/chart

# uninstall
helm uninstall my-release
```

### `helm rollback`

```shell
helm rollback my-release 1
```

> [!NOTE]
> Rollback will actually create a new release (incrementing sequence number) instead of going back.
> Values/configuration will be copied from the old release to the new one.

### `helm uninstall`

```shell
helm uninstall my-release
```

## Helm Controller

See: [Helm Controller GitHub repository](https://github.com/k3s-io/helm-controller).

Helm Controller is an external addon not installed by Helm, you need to install it yourself.

Or on Kubernetes distributions like k3s or RKE2, Helm controller is available by default.

Installs Helm release from Kubernetes Custom Resource.

- `HelmRelease`
- `HelmReleaseConfig`

> [!IMPORTANT]
> `k3s-io/helm-controller` and `fluxcd/helm-controller` are two different projects, even though they carry the same name!

## Kustomize

- [Website](https://kustomize.io/)
- [Docs](https://kubectl.docs.kubernetes.io/)

*Kustomize* is using overlays and hierarchy-based merging of manifests unlike Helm, which is creating packages.

## GitOps

Static manifests, Helm charts, and *Kustomize* are stored in Git repository and are applied to the cluster from there on pull-based model. Usually a pro-active solution is hosted in the cluster.

- [ArgoCD](https://argoproj.github.io/argo-cd/)
- [Flux](https://fluxcd.io/)

## Networking

Kubernetes by default runs two networks backed by CNI plugin and kube-proxy on each node.

Locally on each node, networking is handled by [**iptables**](https://en.wikipedia.org/wiki/Iptables), altho there is an [ongoing effort](https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/3866-nftables-proxy/README.md) to migrate to more modern and performant [**nftables**](https://nftables.org/).

### Subnets

It is useful to know your CIDRs, when debugging issues, so you can spot where the network traffic is heading and if it's a correct location.

Subnet CIDRs:

- *Service* subnet (default CIDR: `10.43.0.0/16`)
- *Pod* subnet (default CIDR: `10.42.0.0/16`)

> [!NOTE]
> CIDRs may vary depending on your Kubernetes distribution or cluster configuration.

### Network Policy

*NetworkPolicy* is a Kubernetes resource describing L4 (TCP/UDP) policies of what kind of workload can talk to what.

Including in-cluster resources (other workload, DNS,...), ingress, and egress policies.

For example highly sensitive workload may not be allowed to connect to anything outside of the cluster, to prevent leaking of sensitive information in case of an attack.

### Cluster DNS addon

- kube-dns
- coredns (mostly default today)

### Cilium Network Policy

If you are using [Cilium](https://cilium.io/) as your CNI plugin, you can use the *CiliumNetworkPolicy*, which allows for more fine-grained control over the network traffic. Thanks to introducing L7 (HTTP) policies.

### CNI plugins

Kubernetes offers an API interface, that allows vendors to develop custom networking solutions, that will handle networking between *Pods* and *Services*.

List of commonly used CNI plugins:

- [Flannel](https://github.com/flannel-io/flannel)
- [Calico](https://www.projectcalico.org/)
- [Cilium](https://cilium.io/)
- [AWS VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s)

> [!NOTE]
> AWS VPC CNI is CNI plugin that allows your nodes to use AWS Elastic Network Interface on your EC2 instances for Kubernetes networking. Using this is recommended to utilized existing systems and not creating another networking layer on top of it.

## Pod Security Admission

### Pod Security Policy

- Removed in Kubernetes 1.25 (released: 23 August, 2022)

## Metrics

All Kubernetes components are exposing metrics in Prometheus format.

### Prometheus

### Prometheus operator and kube-prometheus-stack helm chart

## Logging

### Elastic Cloud on Kubernetes (ECK)

### Grafana Loki

### Other

Cloud integrations like AWS CloudWatch, Azure Monitor, Google Cloud Operations Suite.

- Fluentd
- Splunk
- DataDog

## Extending Kubernetes

### Operators

Operators are extensions to Kubernetes that make use of custom resources to manage applications and their components.

For example, [*RedHat OpenShift*](https://www.redhat.com/en/technologies/cloud-computing/openshift) (Kubernetes distribution by RedHat) is heavily utilizing operators.

### Kubebuilder

Kubernetes SDK for building *Operators* and *Controllers*.

- [The Kubebuilder Book](https://book.kubebuilder.io/)
- [GitHub repository](https://github.com/kubernetes-sigs/kubebuilder)

### Operator Framework

If you want to use *Operator Lifecycle Manager* or integrate more with Kubernetes distribution like *RedHat OpenShift*, use *Operator Framework*.

*Operator Framework* is built on top of *Kubebuilder*, so you do not need to learn new APIs, it just brings some more functionality and integration with *OLM*.

The Operator Framework projects offers [Operator SDK](https://github.com/operator-framework/operator-sdk).

### Operator Lifecycle Manager (OLM)

Operator to manage operators.

Integrated with *RedHat OpenShift*, making it easy installing operators from OpenShift Admin Console.

### Cluster API

[Cluster API website](https://cluster-api.sigs.k8s.io/)

Kubernetes project's solution to provisioning, operating, and upgrading multiple clusters.

## Links

- [Kubernetes documentation](https://kubernetes.io/docs/home/)
- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [ArtifactHub (helm charts)](https://artifacthub.io/)
- [OperatorHub](https://operatorhub.io/)

## Questions?

## Thank you, that's all 👋

## Vojtěch Mareš

- Email me at [iam@vojtechmares.com](mailto:iam@vojtechmares.com)
- Website: [vojtechmares.com](https://www.vojtechmares.com)
- My other trainings: [vojtechmares.com/#skoleni](https://www.vojtechmares.com/#skoleni)
- X: [@vojtechmares](https://x.com/vojtechmares)
- GitHub: [github.com/vojtechmares](https://github.com/vojtechmares)
- LinkedIn: [linkedin.com/in/vojtech-mares](https://www.linkedin.com/in/vojtech-mares)
