#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
export PATH=$PATH:$DIR/qubeship_home/bin

set -o allexport
source $DIR/qube_common_functions.sh
eval $(get_options $@)
if [ "$return_code" -eq 1 ]; then
    exit $return_code
fi
set -e
if [ $verbose ]; then
    set -x
fi

if [ -n $github_org ]; then
    SYSTEM_GITHUB_ORG=$github_org
fi

if [ -e .client_env ]; then
    source $DIR/.client_env
fi

if [ -e ~/.qube_cli_profile ]; then
    source ~/.qube_cli_profile
fi

if [ -e $SCM_CONFIG_FILE ] ; then
    source $SCM_CONFIG_FILE
fi

if [ -e $BETA_CONFIG_FILE ] ; then
    source $BETA_CONFIG_FILE
fi

orgId=$(qube auth user-info --org | jq -r '.tenant.orgs[0].id')
sed "s/<SYSTEM_GITHUB_ORG>/${orgId}/g" load.js.template | sed  "s/beta_access/${is_beta:-false}/g" | sed "s/install_registry/${install_registry:-false}/g" | sed "s/install_target_cluster/${install_target_cluster:-false}/g"  > load.js

docker cp load.js $(docker-compose ps -q qube_mongodb 2>/dev/null):/tmp
docker-compose exec qube_mongodb sh -c "mongo < /tmp/load.js" 2>/dev/null

qube_service_configuration_complete="false"
RUN_VAULT_CMD="docker-compose exec qube-vault vault"
$RUN_VAULT_CMD auth $VAULT_TOKEN

QUBE_BUILDER_CREDENTIALS=$($RUN_VAULT_CMD read --format=json secret/resources/$TENANT/$ENV_TYPE/$ENV_ID/qubebuilder)
qubebuilder_username=$(echo $QUBE_BUILDER_CREDENTIALS | jq -r .data.user)
access_token=$(echo $QUBE_BUILDER_CREDENTIALS | jq -r .data.access_token)

url_ready -s $QUBE_BUILDER_URL
CRUMB=$(curl -u $qubebuilder_username:$access_token -s $QUBE_BUILDER_URL/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))

set +e +x
#if [ $verbose ]; then
#fi
for i in `seq 1 3`;
do
    url_ready -H $CRUMB -u $qubebuilder_username:$access_token -s $QUBE_BUILDER_URL
    output=$(qube service postconfiguration | jq -r '.status')
    if [  "$output"=="Accepted"  ]; then
        qube_service_configuration_complete="true"
        echo "post configuration completed"
        break
    fi
    sleep 20
done

if [ "$qube_service_configuration_complete" == "false" ]; then
    echo "error in qube service configuration. please rerun post configuration step ./postconfiguration.sh"
    exit 1
fi
if [ $verbose ]; then
    set -x
fi

# $DIR/run.sh
# set +x
# qube service postconfiguration

echo "=================================================="
echo "Your Qubeship Installation is ready for use!!!!"
echo "Here are some useful urls!!!!"
echo "API: $API_URL_BASE"
echo "You can use your GITHUB credentials to login !!!!"
if [ ! -z $BETA_ACCESS_USERNAME ];  then
    echo "APP: $APP_URL"
fi
echo "=================================================="
