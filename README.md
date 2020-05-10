# Ansible

### Error "ssh: connect to host localhost port 22: Connection refused"
```
ansible@DESKTOP-HH72KMH:~$ ssh ansible@localhost
ssh: connect to host localhost port 22: Connection refused

ansible@DESKTOP-HH72KMH:~$ exit

root@DESKTOP-HH72KMH:~# service ssh restart
 * Restarting OpenBSD Secure Shell server sshd			[ OK ]
root@DESKTOP-HH72KMH:~# sudo su - ansible

ansible@DESKTOP-HH72KMH:~$ ssh ansible@localhost
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.4.0-18362-Microsoft x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun May 10 15:27:01 CEST 2020

  System load:    0.52      Memory usage: 82%   Processes:       25
  Usage of /home: unknown   Swap usage:   3%    Users logged in: 0

  => There were exceptions while processing one or more plugins. See
     /var/log/landscape/sysinfo.log for more information.


  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

15 packages can be updated.
10 updates are security updates.


Last login: Sun May 10 15:26:45 2020 from 127.0.0.1
ansible@DESKTOP-HH72KMH:~$
```

# Nginx

### Error: could not find tiller
```
$ helm version
Client: &version.Version{SemVer:"v2.16.6", GitCommit:"dd2e5695da88625b190e6b22e9542550ab503a47", GitTreeState:"clean"}
Error: could not find tiller
```

```
$ kubectl -n kube-system delete deployment tiller-deploy
deployment.extensions "tiller-deploy" delete
$ kubectl -n kube-system delete service/tiller-deploy
service "tiller-deploy" deleted
$ helm init
$HELM_HOME has been configured at /home/mathieu_bretaud/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://v2.helm.sh/docs/securing_installation/
```

```
$ helm version
Client: &version.Version{SemVer:"v2.16.6", GitCommit:"dd2e5695da88625b190e6b22e9542550ab503a47", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.6", GitCommit:"dd2e5695da88625b190e6b22e9542550ab503a47", GitTreeState:"clean"}
```

### Install Nginx Ingress Controller
```
$ helm repo add nginx-stable https://helm.nginx.com/stable
"nginx-stable" has been added to your repositories
```

```
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "nginx-stable" chart repository
```

```
$ helm install --name nginx-ingress stable/nginx-ingress --set controller.publishService.ena
bled=true
NAME:   nginx-ingress
LAST DEPLOYED: Sun May 10 11:52:50 2020
NAMESPACE: jenkins
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME           AGE
nginx-ingress  0s

==> v1/ClusterRoleBinding
NAME           AGE
nginx-ingress  0s

==> v1/Deployment
NAME                           READY  UP-TO-DATE  AVAILABLE  AGE
nginx-ingress-controller       0/1    1           0          0s
nginx-ingress-default-backend  0/1    1           0          0s

==> v1/Pod(related)
NAME                                            READY  STATUS             RESTARTS  AGE
nginx-ingress-controller-8774b9d4c-btmsj        0/1    ContainerCreating  0         0s
nginx-ingress-default-backend-674d599c48-kzr48  0/1    ContainerCreating  0         0s
nginx-ingress-controller-8774b9d4c-btmsj        0/1    ContainerCreating  0         0s
nginx-ingress-default-backend-674d599c48-kzr48  0/1    ContainerCreating  0         0s

==> v1/Role
NAME           AGE
nginx-ingress  0s

==> v1/RoleBinding
NAME           AGE
nginx-ingress  0s

==> v1/Service
NAME                           TYPE          CLUSTER-IP     EXTERNAL-IP  PORT(S)                     AGE
nginx-ingress-controller       LoadBalancer  10.103.218.35  <pending>    80:30253/TCP,443:32585/TCP  0s
nginx-ingress-default-backend  ClusterIP     10.104.44.178  <none>       80/TCP                      0s

==> v1/ServiceAccount
NAME                   SECRETS  AGE
nginx-ingress          1        0s
nginx-ingress-backend  1        0s


NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace jenkins get services -o wide -w nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

```
$ kubectl get services -o wide -w nginx-ingress-controller
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
nginx-ingress-controller   LoadBalancer   10.103.218.35   <pending>     80:30253/TCP,443:32585/TCP   52s   app.kubernetes.io/component=controller,app=nginx-ingress,release=nginx-ingress
```

# Kubernetes Dashboard

### Launch the Dashboard
```
$ kubectl proxy --address=0.0.0.0 --accept-hosts='.*'
Starting to serve on 127.0.0.1:8001
2020/05/07 11:55:56 http: proxy error: context canceled
```

### Add the token in the kubeconfig file for the User "docker-desktop"
```
$ TOKEN=$(kubectl -n kube-system describe secret default| awk '$1=="token:"{print $2}')
$ kubectl config set-credentials docker-desktop --token="${TOKEN}"
User "docker-desktop" set.
```

### Check the token is present in the kubeconfig file for the User "docker-desktop"
```
$ kubectl config view |cut -c1-50|tail -10
  name: docker-for-desktop
current-context: docker-desktop
kind: Config
preferences: {}
users:
- name: docker-desktop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3
```

# Kubeconfig

```
$ kubectl get serviceAccounts
NAME      SECRETS   AGE
default   1         42h
```

```
$ kubectl describe serviceAccounts default
Name:                default
Namespace:           jenkins
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   default-token-dmhng
Tokens:              default-token-dmhng
Events:              <none>
```

```
$ kubectl describe secrets default-token-dmhng
Name:         default-token-dmhng
Namespace:    jenkins
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: a51a884c-bd08-46ef-8b0a-191182d09a1f

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJqZW5raW5zIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tZG1obmciLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImE1MWE4ODRjLWJkMDgtNDZlZi04YjBhLTE5MTE4MmQwOWExZiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpqZW5raW5zOmRlZmF1bHQifQ.eHkjhStHR09YXJZj7KAua0suQMFiK_1kSqkSPRGJ3eFbZJauADtzogkTyTGPV4158i4NHYzXoT6bnhF4eHPiUiHzylsExnLh1NE6MVoG70UC_fX0Nk2SDj6wGIn42Rlj6fay5pZtsMZ-e0vqM0LP6YhFyWHFdLmSm2Qni9ZDSs3fhCz_heZfeKvTKmZJKAqLfM29FD1iWFeD5IPrbrMY33vBQp0y37C77q9cRSgNC1tV21yvsP91KrpVb0N6Fv0ZQsQEmRLsSjptdZ_LR50HVdWBAQdwTDTnyTQFPvfSMyeR_XB34UpvdhlHE7saSUmEqudLrU0AK2HR5RPqO89Yug
ca.crt:     1025 bytes
namespace:  7 bytes
```




# Namespace

## Create the yaml file
```
$ cat jenkins-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
  labels:
    name: production
```

## Deploy the creation of the Namespace
```
$ kubectl create -f jenkins-namespace.yaml
namespace/jenkins created
```

## Display the list of the Namespaces with the labels
```
$ kubectl get namespaces --show-labels
NAME              STATUS   AGE     LABELS
default           Active   29h     <none>
docker            Active   29h     <none>
jenkins           Active   2m55s   name=production
kube-node-lease   Active   29h     <none>
kube-public       Active   29h     <none>
kube-system       Active   29h     <none>
```

## Display the description of the Namespace
```
$ kubectl describe namespaces jenkins
Name:         jenkins
Labels:       name=production
Annotations:  Status:  Active

No resource quota.

No LimitRange resource.
```

## Change the Namespace
```
$ kubectl config set-context $(kubectl config current-context) --namespace=jenkins
Context "docker-desktop" modified.
```

## Display the current Namespace
```
$ kubectl config get-contexts
CURRENT   NAME                 CLUSTER          AUTHINFO         NAMESPACE
*         docker-desktop       docker-desktop   docker-desktop   jenkins
          docker-for-desktop   docker-desktop   docker-desktop
```

# PersistentVolume

## Create the directory of the volume
```
$ mkdir /m/Docker/Volumes/jenkins-master/jenkins_home
```

## Create the yaml file
```
$ cat jenkins-pv.yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: jenkins-pv
  namespace: jenkins
  labels:
    type: local
spec:
  storageClassName: jenkins
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/m/Docker/Volumes/jenkins-master/jenkins_home"
```

## Deploy the creation of the PersistentVolume
```
$ kubectl create -f jenkins-pv.yaml
persistentvolume/jenkins-pv created
```

## Display the PersistentVolume
```
$ kubectl get pv jenkins-pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
jenkins-pv   10Gi       RWO            Retain           Available           jenkins                 22s
```

## Display the description of the PersistentVolume
```
$ kubectl describe pv jenkins-pv
Name:            jenkins-pv
Labels:          type=local
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    jenkins
Status:          Available
Claim:
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        10Gi
Node Affinity:   <none>
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /m/Docker/Volumes/jenkins-master/jenkins_home
    HostPathType:
Events:            <none>
```

# PersistentVolumeClaim

## Create the yaml file
```
$ cat jenkins-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jenkins-pvc
  namespace: jenkins
  labels:
    type: local
spec:
  storageClassName: jenkins
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

## Deploy the creation of the PersistentVolumeClaim
```
$ kubectl create -f jenkins-pvc.yaml
persistentvolumeclaim/jenkins-pvc created
```

## Display the PersistentVolumeClaim
```
$ kubectl get pvc jenkins-pvc
NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
jenkins-pvc   Bound    jenkins-pv   10Gi       RWO            jenkins        10s
```

## Display the description of the PersistentVolumeClaim
```
$ kubectl describe pvc jenkins-pvc
Name:          jenkins-pvc
Namespace:     jenkins
StorageClass:  jenkins
Status:        Bound
Volume:        jenkins-pv
Labels:        type=local
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      10Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Mounted By:    <none>
Events:        <none>
```

# Deployment

## Create the yaml file
```
$ cat jenkins-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
        - name: jenkins-master-container
          image: jenkins-master:2.233
          env:
            - name: JAVA_OPTS
              value: -Djenkins.install.runSetupWizard=false
          ports:
            - name: http-port
              containerPort: 8080
            - name: jnlp-port
              containerPort: 50000
          volumeMounts:
            - name: jenkins-home
              mountPath: "/var/jenkins_home"
      volumes:
        - name: jenkins-home
          persistentVolumeClaim:
              claimName: jenkins-pvc
```

## Deploy the creation of the pods
```
$ kubectl create -f jenkins-deployment.yaml
deployment.extensions/jenkins created
```

## Display the list of pods
```
$ kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
jenkins-667f6b75c9-zndns   1/1     Running   0          17s
```

## Display the list of deployments
```
$ kubectl get deployments
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
jenkins   1/1     1            1           14m
```

## Display the description of the deployment
```
$ kubectl describe deployments jenkins
Name:                   jenkins
Namespace:              jenkins
CreationTimestamp:      Wed, 06 May 2020 17:42:26 +0200
Labels:                 app=jenkins
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=jenkins
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
Pod Template:
  Labels:  app=jenkins
  Containers:
   jenkins-master-container:
    Image:       jenkins-master:2.233
    Ports:       8080/TCP, 50000/TCP
    Host Ports:  0/TCP, 0/TCP
    Environment:
      JAVA_OPTS:  -Djenkins.install.runSetupWizard=false
    Mounts:
      /var/jenkins_home from jenkins-home (rw)
  Volumes:
   jenkins-home:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  jenkins-pvc
    ReadOnly:   false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   jenkins-667f6b75c9 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  38s   deployment-controller  Scaled up replica set jenkins-667f6b75c9 to 1
```

# Service

## Create the yaml file
```
$ cat jenkins-services.yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
  selector:
    app: jenkins

---

apiVersion: v1
kind: Service
metadata:
  name: jenkins-jnlp
  namespace: jenkins
spec:
  type: ClusterIP
  ports:
    - port: 50000
      targetPort: 50000
  selector:
    app: jenkins
```

## Deploy the creation of the Service
```
$ kubectl create -f jenkins-services.yaml
service/jenkins created
```

## Display the Service
```
$ kubectl get service
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
jenkins   NodePort   10.100.111.51   <none>        8080:31846/TCP   5s
```

# Execution

## Enter into the pod
```
$ kubectl exec jenkins-667f6b75c9-zndns -i -t -- /bin/sh
/ $ printenv
JENKINS_HOME=/var/jenkins_home
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_SERVICE_PORT=443
JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
JAVA_ALPINE_VERSION=8.121.13-r0
HOSTNAME=jenkins-667f6b75c9-zndns
SHLVL=1
HOME=/var/jenkins_home
JENKINS_UC=https://updates.jenkins.io
REF=/usr/share/jenkins/ref
JAVA_VERSION=8u121
TERM=xterm
JENKINS_VERSION=2.233
JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
JAVA_OPTS=-Djenkins.install.runSetupWizard=false
LANG=C.UTF-8
JENKINS_SLAVE_AGENT_PORT=50000
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_SERVICE_PORT_HTTPS=443
PWD=/
COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log
JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
KUBERNETES_SERVICE_HOST=10.96.0.1
/ $ exit
$
```

## Display the description of the Pod
```
$ kubectl describe pod jenkins-667f6b75c9-zndns
Name:           jenkins-667f6b75c9-zndns
Namespace:      jenkins
Priority:       0
Node:           docker-desktop/192.168.65.3
Start Time:     Wed, 06 May 2020 17:42:26 +0200
Labels:         app=jenkins
                pod-template-hash=667f6b75c9
Annotations:    <none>
Status:         Running
IP:             10.1.0.150
IPs:            <none>
Controlled By:  ReplicaSet/jenkins-667f6b75c9
Containers:
  jenkins-master-container:
    Container ID:   docker://d587a8ced06313176c536465e36d554b9daf18673d2f298122cc865e479c63c8
    Image:          jenkins-master:2.233
    Image ID:       docker://sha256:0d236ff4260e0eab8c67e7c7f62088d93ef9963039fb6e69c0edf8325fc09d5c
    Ports:          8080/TCP, 50000/TCP
    Host Ports:     0/TCP, 0/TCP
    State:          Running
      Started:      Wed, 06 May 2020 17:42:27 +0200
    Ready:          True
    Restart Count:  0
    Environment:
      JAVA_OPTS:  -Djenkins.install.runSetupWizard=false
    Mounts:
      /var/jenkins_home from jenkins-home (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-dmhng (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  jenkins-home:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  jenkins-pvc
    ReadOnly:   false
  default-token-dmhng:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-dmhng
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From                     Message
  ----    ------     ----   ----                     -------
  Normal  Scheduled  2m22s  default-scheduler        Successfully assigned jenkins/jenkins-667f6b75c9-zndns to docker-desktop
  Normal  Pulled     2m21s  kubelet, docker-desktop  Container image "jenkins-master:2.233" already present on machine
  Normal  Created    2m21s  kubelet, docker-desktop  Created container jenkins-master-container
  Normal  Started    2m21s  kubelet, docker-desktop  Started container jenkins-master-container
```

# Replicasets

## Display the list of replicasets
```
$ kubectl get replicasets
NAME                 DESIRED   CURRENT   READY   AGE
jenkins-667f6b75c9   1         1         1       15m
```

## Display the description of the replicasets
```
$ kubectl describe replicasets jenkins-667f6b75c9
Name:           jenkins-667f6b75c9
Namespace:      jenkins
Selector:       app=jenkins,pod-template-hash=667f6b75c9
Labels:         app=jenkins
                pod-template-hash=667f6b75c9
Annotations:    deployment.kubernetes.io/desired-replicas: 1
                deployment.kubernetes.io/max-replicas: 2
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/jenkins
Replicas:       1 current / 1 desired
Pods Status:    1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=jenkins
           pod-template-hash=667f6b75c9
  Containers:
   jenkins-master-container:
    Image:       jenkins-master:2.233
    Ports:       8080/TCP, 50000/TCP
    Host Ports:  0/TCP, 0/TCP
    Environment:
      JAVA_OPTS:  -Djenkins.install.runSetupWizard=false
    Mounts:
      /var/jenkins_home from jenkins-home (rw)
  Volumes:
   jenkins-home:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  jenkins-pvc
    ReadOnly:   false
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  2m52s  replicaset-controller  Created pod: jenkins-667f6b75c9-zndns
```

# Expose ports

## Export the port of the Service
```
$ kubectl port-forward service/jenkins 8080:8080 &
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```
