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
