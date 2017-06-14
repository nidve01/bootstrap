#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
set -o allexport
source $DIR/qube_common_functions.sh
set +x
get_options $@ > /dev/null
#eval $(get_options $@)
if [ "$return_code" -eq 1 ]; then
    exit $return_code
fi

if [ ! -z "$DOCKER_INSTALL_TYPE" ]; then
    if [ "$DOCKER_INSTALL_TYPE" == "mac" ]; then
        echo "ERROR: Qubeship installation on docker for mac is still on roadmap. please install docker toolbox instead"
    fi
fi
source .env
touch .client_env
set -e
if [ $verbose ]; then
    set -x
fi

echo "register-qubeship.sh: $( date ) : starting registering qubeship with github"

if [ -f $BETA_CONFIG_FILE ]; then
    echo "sourcing $BETA_CONFIG_FILE"
    source $BETA_CONFIG_FILE
else
    echo "ERROR: community edition is not supported"
    exit -1
fi

if [ $is_beta ];  then
    echo "login to Qubeship docker registry"
    docker login -u $BETA_ACCESS_USERNAME -p $BETA_ACCESS_TOKEN quay.io
    if [ $? -ne 0 ]; then
        echo "ERROR : failed to do docker login. please check your docker installation"
        exit 1
    fi
fi

if [ -z "$github_username" ] ; then
    echo "ERROR: missing username"
    show_help register-qubeship.sh
    exit -1
fi

if [ -z "$github_password" ] ; then
    echo "ERROR: missing password"
    show_help register-qubeship.sh
    exit -1
fi

if [ -e $SCM_CONFIG_FILE ] ; then
  echo "cleaning the previously configured scm.config file"
  rm -rf $SCM_CONFIG_FILE
fi


if [ -z $DOCKER_HOST ]; then
    echo "DOCKER_HOST is not defined. Please run again from docker terminal"
    exit -1
fi
QUBE_HOST=$(echo $DOCKER_HOST | awk '{ sub(/tcp:\/\//, ""); sub(/:.*/, ""); print $0}')


docker-compose $files pull oauth_registrator
docker-compose $files run oauth_registrator $resolved_args  2>/dev/null | grep -v "# " | awk '{gsub("\r","", $0);print}' > $SCM_CONFIG_FILE
source $SCM_CONFIG_FILE
for key in $(echo GITHUB_CLI_CLIENTID GITHUB_CLI_SECRET GITHUB_BUILDER_CLIENTID GITHUB_CLI_SECRET); do
  value=${!key}
  if [ -z $value ]; then
      cat $SCM_CONFIG_FILE
      echo "There is an error registering with github. You may want to configure manually https://github.com/Qubeship/bootstrap/blob/community_beta/README-githubconfiguration.md"
      rm -rf $SCM_CONFIG_FILE
      exit -1
  fi
done
echo "Qubeship is successfull registered with github. Please verify other pre-requisites and proceed with install https://github.com/Qubeship/bootstrap/blob/community_beta/README.md#install"
