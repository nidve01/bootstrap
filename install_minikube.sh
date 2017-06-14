#!/usr/bin/env bash

vboxloc=`which VirtualBox`
if [ -z $vboxloc ]; then
    echo "VirtualBox is missing"
    exit -1;
fi

if [ "$(uname)" == "Darwin" ]
then
  echo "DEBUG: detected OSX"
    #brew cask install minikube
  minikube_url=https://storage.googleapis.com/minikube/releases/v0.19.0/minikube-darwin-amd64
  kubectl_url=http://storage.googleapis.com/kubernetes-release/release/v1.6.0/bin/darwin/amd64/kubectl
else
  echo "DEBUG: detected linux"
  if [ "$EUID" -ne 0 ]; then
     echo "ERROR: Please run as root"
     exit -1;
  fi
  minikube_url=https://storage.googleapis.com/minikube/releases/v0.19.0/minikube-linux-amd64
  kubectl_url=http://storage.googleapis.com/kubernetes-release/release/v1.6.0/bin/linux/amd64/kubectl
fi

if [ -z $(which minikube | grep qubeship_home ) ]; then
    curl -sLo minikube $minikube_url && chmod +x minikube && mv minikube /usr/local/bin
else
    echo "DEBUG: minikube already present"
fi
if [  -z $(which kubectl | grep qubeship_home) ]; then
    curl -sLo kubectl $kubectl_url && chmod +x kubectl &&  mv kubectl /usr/local/bin
else
    echo "DEBUG: kubectl already present"
fi

minikube_context=$(/usr/local/bin/kubectl config get-contexts | grep minikube | awk '{print $2}')
if [ ! -z $minikube_context ] ; then
    echo "INFO: minikube already exists"
    kubectl config use-context minikube
fi

echo "INFO: confirming minikube is running"
if [ $(/usr/local/bin/kubectl config  current-context) != "minikube" ]; then
    echo "WARN: minikube context not found...attempting to start"
    /usr/local/bin/minikube start
fi

if [ $(/usr/local/bin/kubectl config  current-context) != "minikube" ]; then
    echo "ERROR: minikube configuration failed. endpoint configuration may not be successful"
    exit 0
fi

get_minikube_status() {
  vmstatus=$(/usr/local/bin/minikube status | grep "minikubeVM:" | awk -F":" '{gsub(/ /,"",$2); print $2}' | tr '[:upper:]' '[:lower:]')
  kubestatus=$(/usr/local/bin/minikube status | grep "localkube:" | awk -F":" '{gsub(/ /,"",$2); print $2}' | tr '[:upper:]' '[:lower:]')
}

get_minikube_status
if [ \( "$vmstatus" != "running" \) -o  \( "$kubestatus" != "running" \) ]; then
    /usr/local/bin/minikube start
else
    echo "DEBUG: minikube already running"
fi
minikube_ip=$(/usr/local/bin/minikube ip)
if [  "$minikube_ip" == "" ]; then
    echo "ERROR: unable to identify minikube ip. endpoint configuration may not be successful"
    exit 0
fi

# wait until minikube is running
timeout_count=0
while [ $timeout_count -lt 10 ]
do
  if [ \( "$vmstatus" != "running" \) -o  \( "$kubestatus" != "running" \) ]; then
    timeout_count=$(expr $timeout_count + 1)
    get_minikube_status
  else
    echo "DEBUG: minikube running"
    break
  fi
done


# Setup ingress controller
minikube addons enable ingress

