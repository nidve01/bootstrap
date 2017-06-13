#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

set -o allexport
source $DIR/qube_common_functions.sh
eval $(get_options $@)
echo $resolved_args

if [ $verbose ]; then
    set -x
fi

if [ -e .client_env ]; then
    source .client_env
fi

if [ -e $SCM_CONFIG_FILE ] ; then
    source $SCM_CONFIG_FILE
fi

if [ -e $BETA_CONFIG_FILE ] ; then
    source $BETA_CONFIG_FILE
fi

if [ -e ~/.qube_cli_profile ]; then
    source ~/.qube_cli_profile
fi

if [ $is_osx ]; then
    if [ "$DOCKER_INSTALL_TYPE" == "mac" ] ; then
        chmod a+rwx /var/run/docker.sock
    else
        docker-machine ssh default sudo chmod a+rwx /var/run/docker.sock
    fi
else
    chmod a+rwx /var/run/docker.sock
fi
set -e

base_command="docker-compose"
options="up -d --remove-orphans"

if [ $is_beta ]; then
    docker login -u $BETA_ACCESS_USERNAME -p $BETA_ACCESS_TOKEN quay.io
    export LISTENER_URL=$NGROK_HOSTNAME
fi

echo "LISTENER URL is : $LISTENER_URL"
docker-compose pull cli
echo "starting $base_command $files $options"
$base_command $files $options

extra_args=""
if [ ! -z $github_username ]; then
    extra_args="--username $github_username --password $github_password --organization $SYSTEM_GITHUB_ORG --skip-defaults"
    qube auth login $extra_args
fi
