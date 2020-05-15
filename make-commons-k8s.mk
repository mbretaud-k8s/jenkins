#
# You need to define

all:

KEY = $(CURRENT_DIR)/secrets/ssl/tls.key
CERT = $(CURRENT_DIR)/secrets/ssl/tls.crt
POD_NAME=$(shell kubectl get pods --namespace=jenkins --output='json' | jq ".items | .[] | .metadata | select(.name | startswith(\"jenkins\")) | .name" | head -1 | sed 's/"//g')

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make deploy    - create resources from files"
	@echo "   2. make apply     - apply configurations to the resources"
	@echo "   3. make delete    - delete resources"
	@echo "   4. make describe  - show details of the resources"
	@echo "   5. make get       - display one or many resources"
	@echo "   6. make change	- change namespace"
	@echo ""

###############################################
#
# Deploy
#
###############################################
deploy:
	kubectl create -f jenkins-namespace.yaml --save-config
	@sleep 1
	mkdir -p $(CURRENT_DIR)/secrets/ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(KEY) -out $(CERT) -subj "/CN=nginxsvc/O=nginxsvc"
	@sleep 1
	kubectl create secret tls nginxsecret --namespace=jenkins --key $(KEY) --cert $(CERT) --save-config
	@sleep 1
	kubectl create -f jenkins-pv.yaml --save-config
	@sleep 1
	kubectl create -f jenkins-pvc.yaml --save-config
	@sleep 1
	kubectl create -f jenkins-deployment.yaml --save-config
	@sleep 1
	kubectl create -f jenkins-services.yaml --save-config
	@sleep 1
	kubectl create -f jenkins-ingress.yaml --save-config
	@sleep 1

###############################################
#
# Apply
#
###############################################
apply:
	kubectl apply -f jenkins-pv.yaml --save-config
	kubectl apply -f jenkins-pvc.yaml --save-config
	kubectl apply -f jenkins-deployment.yaml --save-config
	kubectl apply -f jenkins-services.yaml --save-config
	kubectl apply -f jenkins-ingress.yaml --save-config

###############################################
#
# Delete
#
###############################################
delete:
	kubectl delete deployment.apps/jenkins --force --ignore-not-found
	kubectl delete secret/nginxsecret --force --ignore-not-found
	kubectl delete persistentvolumeclaim/jenkins-pvc --force --ignore-not-found
	kubectl delete persistentvolume/jenkins-pv --force --ignore-not-found
	kubectl delete service/jenkins --force --ignore-not-found
	kubectl delete service/jenkins-jnlp --force --ignore-not-found
	kubectl delete ingress.networking.k8s.io/jenkins-ingress --force --ignore-not-found
	kubectl delete namespace/jenkins --force --ignore-not-found

###############################################
#
# Describe
#
###############################################
describe:
	@echo "---------------------------"
	kubectl describe namespace/jenkins --namespace=jenkins
	@echo ""
	
	kubectl describe deployment.apps/jenkins --namespace=jenkins
	@echo ""
	
	kubectl describe secret/nginxsecret --namespace=jenkins
	@echo ""
	
	kubectl describe persistentvolumeclaim/jenkins-pvc --namespace=jenkins
	@echo ""
	
	kubectl describe persistentvolume/jenkins-pv --namespace=jenkins
	@echo ""
	
	kubectl describe service/jenkins --namespace=jenkins
	@echo ""
	
	kubectl describe service/jenkins-jnlp --namespace=jenkins
	@echo ""
	
	kubectl describe ingress.networking.k8s.io/jenkins-ingress --namespace=jenkins
	@echo ""
	@echo "---------------------------"

###############################################
#
# Get
#
###############################################
get:
	@echo "---------------------------"
	kubectl get namespace/jenkins --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get deployment.apps/jenkins --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get secret/nginxsecret --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get persistentvolumeclaim/jenkins-pvc --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get persistentvolume/jenkins-pv --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get service/jenkins --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get service/jenkins-jnlp --namespace=jenkins --ignore-not-found
	@echo ""
	
	kubectl get ingress.networking.k8s.io/jenkins-ingress --namespace=jenkins --ignore-not-found
	@echo ""
	@echo "---------------------------"

###############################################
#
# Change Namespace
#
###############################################
change:
	kubectl config set-context $(shell kubectl config current-context) --namespace=jenkins

###############################################
#
# Get logs from the pod
#
###############################################
logs:
	kubectl logs pod/$(POD_NAME) --namespace=jenkins
