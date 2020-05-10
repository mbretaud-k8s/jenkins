#
# You need to define
#   deploymentFile
#   deploymentName
#	ingressFile
#	ingressName
#	namespaceFile
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
# Deploy
#
###############################################
deploy:

ifneq ($(namespaceFile),)
	kubectl create -f $(namespaceFile) --save-config
endif
ifneq ($(persistentVolumeFile),)
	kubectl create -f $(persistentVolumeFile) --save-config
endif
ifneq ($(persistentVolumeClaimFile),)
	kubectl create -f $(persistentVolumeClaimFile) --save-config
endif
ifneq ($(deploymentFile),)
	kubectl create -f $(deploymentFile) --save-config
endif
ifneq ($(serviceFile),)
	kubectl create -f $(serviceFile) --save-config
endif
ifneq ($(ingressFile),)
	kubectl create -f $(ingressFile) --save-config
endif

###############################################
#
# Apply
#
###############################################
apply:
ifneq ($(namespaceFile),)
	kubectl apply -f $(namespaceFile) --save-config
endif
ifneq ($(persistentVolumeFile),)
	kubectl apply -f $(persistentVolumeFile) --save-config
endif
ifneq ($(persistentVolumeClaimFile),)
	kubectl apply -f $(persistentVolumeClaimFile) --save-config
endif
ifneq ($(deploymentFile),)
	kubectl apply -f $(deploymentFile) --save-config
endif
ifneq ($(serviceFile),)
	kubectl apply -f $(serviceFile) --save-config
endif
ifneq ($(ingressFile),)
	kubectl apply -f $(ingressFile) --save-config
endif

###############################################
#
# Delete
#
###############################################
delete:
ifneq ($(persistentVolumeFile),)
	kubectl delete pv/$(persistentVolumeName) --namespace=$(namespaceName)
endif
ifneq ($(persistentVolumeClaimFile),)
	kubectl delete pvc/$(persistentVolumeClaimName) --namespace=$(namespaceName)
endif
ifneq ($(deploymentFile),)
	kubectl delete -f $(deploymentFile) --force --grace-period=0 --namespace=$(namespaceName)
endif
ifneq ($(serviceFile),)
	kubectl delete service/$(serviceName) --namespace=$(namespaceName)
endif
ifneq ($(ingressFile),)
	kubectl delete ing/$(ingressName) --namespace=$(namespaceName)
endif
ifneq ($(namespaceFile),)
	kubectl delete -f $(namespaceFile) --namespace=$(namespaceName)
endif

###############################################
#
# Describe
#
###############################################
describe:
	@echo "---------------------------"
ifneq ($(persistentVolumeFile),)
	kubectl describe pv/$(persistentVolumeName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(persistentVolumeClaimFile),)
	kubectl describe pvc/$(persistentVolumeClaimName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(deploymentFile),)
	kubectl describe pods --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(serviceFile),)
	kubectl describe service/$(serviceName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(ingressFile),)
	kubectl describe ing/$(ingressName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif

###############################################
#
# Get
#
###############################################
get:
	@echo "---------------------------"
ifneq ($(persistentVolumeFile),)
	kubectl get pv/$(persistentVolumeName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(persistentVolumeClaimFile),)
	kubectl get pvc/$(persistentVolumeClaimName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(deploymentFile),)
	kubectl get pods --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(serviceFile),)
	kubectl get service/$(serviceName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
ifneq ($(ingressFile),)
	kubectl get ing/$(ingressName) --namespace=$(namespaceName)
	@echo ""
	@echo "---------------------------"
	@echo ""
endif
