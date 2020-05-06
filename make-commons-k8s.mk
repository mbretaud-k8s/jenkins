#
# You need to define
#   deploymentFile
#   deploymentName
#	namespaceName
#   persistentVolumeFile
#   persistentVolumeName
#   persistentVolumeClaimFile
#   persistentVolumeClaimName
#   serviceFile
#   serviceName

POD_NAME=$(shell kubectl get pods --output='json' | jq ".items | .[] | .metadata | select(.name | startswith(\"$(deploymentName)\")) | .name" | head -1 | sed 's/"//g')

default:

###############################################
#
# PersistentVolume
#
###############################################
create-pv:
	kubectl create -f $(persistentVolumeFile)

delete-pv:
	kubectl delete pv/$(persistentVolumeName) --namespace=$(namespaceName)

describe-pv:
	kubectl describe pv/$(persistentVolumeName) --namespace=$(namespaceName)

get-pv:
	kubectl get pv/$(persistentVolumeName) --namespace=$(namespaceName)

###############################################
#
# PersistentVolumeClaim
#
###############################################
create-pvc:
	kubectl create -f $(persistentVolumeClaimFile)

delete-pvc:
	kubectl delete pvc/$(persistentVolumeClaimName) --namespace=$(namespaceName)

describe-pvc:
	kubectl describe pvc/$(persistentVolumeClaimName) --namespace=$(namespaceName)

get-pvc:
	kubectl get pvc/$(persistentVolumeClaimName) --namespace=$(namespaceName)

###############################################
#
# Pods
#
###############################################
deploy-pods:
	kubectl create -f $(deploymentFile)

delete-pods:
	kubectl delete -f $(deploymentFile) --force --grace-period=0 --namespace=$(namespaceName)

exec-pod:
	kubectl exec pods/$(POD_NAME) --namespace=$(namespaceName) -i -t -- /bin/sh

get-pods:
	kubectl get pods --namespace=$(namespaceName)

get-deployments:
	kubectl get deployments/$(deploymentName) --namespace=$(namespaceName)

###############################################
#
# Services
#
###############################################	
create-service:
	kubectl create -f $(serviceFile)

delete-service:
	kubectl delete service/$(serviceName) --namespace=$(namespaceName)

describe-service:
	kubectl describe service/$(serviceName) --namespace=$(namespaceName)

get-service:
	kubectl get service/$(serviceName) --namespace=$(namespaceName)
