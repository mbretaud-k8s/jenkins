CURRENT_DIR = $(shell pwd)

# Namespace
namespaceName=jenkins

# Deployments of the pods
deploymentFile=jenkins-deployment.yaml
deploymentName=jenkins

# PersistentVolume
persistentVolumeFile=jenkins-pv.yaml
persistentVolumeName=jenkins-pv

# PersistentVolumeClaim
persistentVolumeClaimFile=jenkins-pvc.yaml
persistentVolumeClaimName=jenkins-pvc

# Service
serviceFile=jenkins-service.yaml
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
$(info deploymentFile: $(deploymentFile))
$(info deploymentName: $(deploymentName))
$(info persistentVolumeFile: $(persistentVolumeFile))
$(info persistentVolumeName: $(persistentVolumeName))
$(info persistentVolumeClaimFile: $(persistentVolumeClaimFile))
$(info persistentVolumeClaimName: $(persistentVolumeClaimName))
$(info serviceFile: $(serviceFile))
$(info serviceName: $(serviceName))
$(info )

include $(CURRENT_DIR)/make-commons-k8s.mk
