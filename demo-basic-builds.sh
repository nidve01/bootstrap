#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
if [ -e .client_env ]; then
    source $DIR/.client_env
    source ~/.qube_cli_profile
fi
set +e +x
pguid=$(uuidgen)
jguid=$(uuidgen)
echo "creating python sample project"
qube service create --service-name "QubeFirstPythonProject" --repo-name "$pguid" --language=python
echo "creating java sample project"
qube service create --service-name "QubeFirstJavaProject" --repo-name "$jguid" --language=java