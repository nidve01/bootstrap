#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
set -o allexport +e +x

source $DIR/qube_common_functions.sh
eval $(get_options $@)
if [ "$return_code" -eq 1 ]; then
    exit $return_code
fi

source .env
export PATH=$PATH:$DIR/qubeship_home/bin

# copy .client_env.template to .client_env
output=`docker ps -a`
docker_client_status=$?
if [ $verbose ]; then
    set -x
fi
if [ $docker_client_status -ne 0 ]; then
    echo "ERROR : Docker doesnt seem to be running. is your docker running?"
    exit -1
fi
if [ -s .client_env ]; then
	echo 'ERROR : qubeship is already configured. if you want to rerun install run ./uninstall.sh first'
	exit -1
fi

set  -e

if [ "$(uname)" == "Darwin" ]
then
  echo "detected OSX"
  jq_url=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-osx-amd64
    #brew cask install minikube

else
  echo "detected linux"
  jq_url=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
fi
curl -sLo $DIR/qubeship_home/bin/jq $jq_url && chmod +x $DIR/qubeship_home/bin/jq

QUBE_DOCKER_HOST=${DOCKER_HOST:-localhost}
if [ -z $DOCKER_HOST ]; then
    echo "INFO: DOCKER_HOST is not defined. setting QUBE_DOCKER_HOST to $QUBE_DOCKER_HOST"
fi



# QUBE_CONFIG_FILE=qubeship_home/config/qubeship.config

# if [ ! -e $QUBE_CONFIG_FILE ]; then
# 	echo "ERROR : config file not found $QUBE_CONFIG_FILE"
# 	exit 0
# fi

if [ ! -f /usr/local/bin/docker-compose ]; then
  curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  docker-compose --version
fi


QUBE_CONSUL_SERVICE=qube-consul
QUBE_VAULT_SERVICE=qube-vault
LOG_FILE=qube_vault_log
QUBE_HOST=$(echo $QUBE_DOCKER_HOST | awk '{ sub(/tcp:\/\//, ""); sub(/:.*/, ""); print $0}')
API_URL_BASE=http://$QUBE_HOST:$API_REGISTRY_PORT
APP_URL=http://$QUBE_HOST:$APP_PORT
BUILDER_URL=http://$QUBE_HOST:$QUBE_BUILDER_PORT

consul_access_token=$(uuidgen | tr '[:upper:]' '[:lower:]')
sed "s#\$consul_acl_master_token#$consul_access_token#g" qubeship_home/consul/data/consul.json.template  > qubeship_home/consul/data/consul.json
# copy vault config.json, firebase.json, and consul.json to busybox
docker-compose up -d busybox 2>/dev/null
for file in $(ls $DIR/qubeship_home/vault/data/) ; do
    docker cp qubeship_home/vault/data/$file "$(docker-compose ps -q busybox  2>/dev/null)":/vault/data
done
docker cp qubeship_home/consul/data/consul.json "$(docker-compose ps -q busybox 2>/dev/null)":/consul/config/

# start qube-vault service
docker-compose up -d $QUBE_VAULT_SERVICE $QUBE_CONSUL_SERVICE  2>/dev/null

RUN_VAULT_CMD="docker-compose exec $QUBE_VAULT_SERVICE vault"

# acquire unseal_key and root token
$RUN_VAULT_CMD init -key-shares=1 -key-threshold=1 > $LOG_FILE
UNSEAL_KEY=$(cat $LOG_FILE | awk -F': ' 'NR==1{print $2}' | tr -d '\r')
VAULT_TOKEN=$(cat $LOG_FILE | awk -F': ' 'NR==2{print $2}' | tr -d '\r')

if [ -f $BETA_CONFIG_FILE ]; then
    echo "sourcing $BETA_CONFIG_FILE"
    source $BETA_CONFIG_FILE
else
    echo "INFO: $BETA_CONFIG_FILE not found. possibly running community edition"
fi

if [ -f $SCM_CONFIG_FILE ] ; then
    echo "Found a $SCM_CONFIG_FILE, proceeding with the file..."
    source $SCM_CONFIG_FILE
  else
    echo "$SCM_CONFIG_FILE not found. Please follow pre-requisite step https://github.com/Qubeship/bootstrap/blob/community_beta/README-githubconfiguration.md"
    exit -1
fi

echo "copying client template"
cp client_env.template .client_env
# put key and token to .client_env
sed -ibak "s#<unseal_key>#$UNSEAL_KEY#g" .client_env
sed -ibak "s/<vault_token>/$VAULT_TOKEN/g" .client_env
sed -ibak "s/<vault_addr>/$QUBE_HOST/g" .client_env
sed -ibak "s/<vault_port>/$VAULT_PORT/g" .client_env
sed -ibak "s/<consul_addr>/$QUBE_HOST/g" .client_env
sed -ibak "s/<consul_port>/$CONSUL_PORT/g" .client_env
sed -ibak "s#<api_url_base>#$API_URL_BASE#g" .client_env
sed -ibak "s#<app_url>#$APP_URL#g" .client_env
sed -ibak "s#<qube_builder_url>#$BUILDER_URL#g" .client_env
sed -ibak "s#<qube_host>#$QUBE_HOST#g" .client_env

GITHUB_ENTERPRISE_HOST=${GITHUB_ENTERPRISE_HOST:-https://github.com}

if [ "$GITHUB_ENTERPRISE_HOST" == "https://github.com" ] ; then
    echo "GITHUB_API_URL=https://api.github.com" >> .client_env
else
    echo "GITHUB_API_URL=$GITHUB_ENTERPRISE_HOST/api/v3" >> .client_env
fi
echo "GITHUB_URL=$GITHUB_ENTERPRISE_HOST" >> .client_env
echo "GITHUB_AUTH_URL=$GITHUB_ENTERPRISE_HOST/login/oauth/authorize" >> .client_env
echo "GITHUB_TOKEN_URL=$GITHUB_ENTERPRISE_HOST/login/oauth/access_token" >> .client_env

sed -ibak "s#<system_github_org>#$SYSTEM_GITHUB_ORG#g" .client_env
echo "sourcing .client_env"
source .client_env

auth=$(echo -n $github_username:$github_password | $base64_encode)
data='{
    "client_id" : "'$GITHUB_BUILDER_CLIENTID'",
    "client_secret" : "'$GITHUB_BUILDER_SECRET'",
    "scopes": [
       "write:repo_hook", "read:repo_hook", "read:org", "repo", "user"
    ]
}'
github_token=$(curl -s -X POST \
  $GITHUB_API_URL/authorizations \
  -H "authorization: Basic $auth" \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d "$data" | jq -r .token)


########################## START: VAULT INITIALIZATION ##########################
# unseal vault server
$RUN_VAULT_CMD unseal $UNSEAL_KEY

# vault auth
$RUN_VAULT_CMD auth $VAULT_TOKEN

BASE_PATH="secret/resources"

# write data to vault
# tokens
$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/supertoken value=$VAULT_TOKEN
$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/usercreds_writer_token value=$VAULT_TOKEN
# firebase
$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/firebase_qubeship api_key=$FIREBASE_API_KEY service_key=@/vault/data/qubeship_firebase.json

$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/github_builder_client id=$GITHUB_BUILDER_CLIENTID secret=$GITHUB_BUILDER_SECRET
$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/github_cli_client id=$GITHUB_CLI_CLIENTID secret=$GITHUB_CLI_SECRET
$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/github_gui_client id=$GITHUB_GUI_CLIENTID secret=$GITHUB_GUI_SECRET

$RUN_VAULT_CMD write $BASE_PATH/$TENANT/$ENV_TYPE/$ENV_ID/qubebuilder user=$github_username access_token=$github_token

RUN_CONSUL_CMD="docker-compose exec $QUBE_CONSUL_SERVICE sh"
$RUN_CONSUL_CMD -c 'echo {\"X\":\"X\"}  | consul kv put qubeship/envs/'${ENV_TYPE}'/settings -'
$RUN_CONSUL_CMD -c 'echo {\"X\":\"X\"}  | consul kv put qubeship/envs/'${ENV_TYPE}/${ENV_ID}'/settings -'
########################## END: VAULT INITIALIZATION ##########################


# install qubeship cli
curl -sL http://cli.qubeship.io/install.sh?$(uuidgen) | bash -s $API_URL_BASE $CLI_IMAGE:$CLI_VERSION

