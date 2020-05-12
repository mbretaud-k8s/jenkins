CURRENT_DIR = $(shell pwd)

# Namespace
namespaceFile=jenkins-namespace.yaml
namespaceName=jenkins

# Deployments of the pods
deploymentFile=jenkins-deployment.yaml
deploymentName=jenkins

# Ingress
ingressFile=jenkins-ingress.yaml
ingressName=jenkins-ingress

# PersistentVolume
persistentVolumeFile=jenkins-pv.yaml
persistentVolumeName=jenkins-pv

# PersistentVolumeClaim
persistentVolumeClaimFile=jenkins-pvc.yaml
persistentVolumeClaimName=jenkins-pvc

# Service
serviceFile=jenkins-services.yaml
serviceName=jenkins

$(info ############################################### )
$(info # )
$(info # Environment variables )
$(info # )
$(info ############################################### )
$(info CURRENT_DIR: $(CURRENT_DIR))

$(info )
$(info ############################################### )
$(info # )
$(info # Parameters )
$(info # )
$(info ############################################### )
$(info namespaceFile: $(namespaceFile))
$(info namespaceName: $(namespaceName))
$(info deploymentFile: $(deploymentFile))
$(info deploymentName: $(deploymentName))
$(info ingressFile: $(ingressFile))
$(info ingressName: $(ingressName))
$(info persistentVolumeFile: $(persistentVolumeFile))
$(info persistentVolumeName: $(persistentVolumeName))
$(info persistentVolumeClaimFile: $(persistentVolumeClaimFile))
$(info persistentVolumeClaimName: $(persistentVolumeClaimName))
$(info serviceFile: $(serviceFile))
$(info serviceName: $(serviceName))
$(info )

include $(CURRENT_DIR)/make-commons-k8s.mk
