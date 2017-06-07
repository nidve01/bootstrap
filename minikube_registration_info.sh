 #!/usr/bin/env bash

default_namespace=$(/usr/local/bin/kubectl get namespaces  | grep default | awk '{print $1}')
if [ "$default_namespace" != "default" ]; then
    echo "ERROR: default namespace not found. endpoint configuration may not be successful"
    exit 0
fi
set +e
for i in `seq 1 3`;
do
    DEFAULT_TOKEN_NAME=$(/usr/local/bin/kubectl --namespace=kube-system get serviceaccount default -o jsonpath="{.secrets[0].name}")
    default_token=$(/usr/local/bin/kubectl --namespace=kube-system get secret "$DEFAULT_TOKEN_NAME" -o go-template="{{.data.token}}" | base64 -D)
    if [  "$default_token" == "" ]; then
        echo "ERROR: default token not found. Waiting for 20 secs"
        sleep 20
    else
        break
    fi
done
set -e
if [  "$default_token" == "" ]; then
    echo "ERROR: default token not found. endpoint configuration may not be successful"
    exit 0
fi
api_server=$(/usr/local/bin/kubectl config view  -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.server }')

# validate token
if [ ! "200" = "$(curl -ksw "%{http_code}\\n" -o /dev/null -H "Authorization: Bearer $default_token" $api_server/version)" ]; then
    echo 'ERROR: token is not valid'
    exit 1
fi


echo "Endpoint registration information:"
echo "=================================="
echo "Endpoint IP address   : " $api_server
echo "Endpoint namespace    : " $default_namespace
echo "Endpoint default token: " $default_token
