# Post Install Qubeship Beta

## Basic Demo 

You may see a quick qubeship demo with auto creating sample projects with qubeship and monitor the builds with basic opinion (build only).

```
$ ./demo-basic-builds.sh
{
    "id": "5934354368e4c1c1001f054f3d",
    "project_id": "c66e99f5-28b6-47f7-9170-1f93b655102b",
    "project_location": "http://192.168.99.100:7000/projects/c66e99f5-28b6-47f7-9170-1f93b655102b",
    "project_url": "https://github-isl-01.ca.com/demouser/008435AD-0C10-42A9-A09E-07C7E4CB8800",
    "service": "QubeFirstPythonProject",
    "version": "v2"
}
creating java sample project
{
    "id": "59374f75e4c1c1001f054f3e",
    "project_id": "f7072490-40bb-4f9f-a6ee-d79fcf783666",
    "project_location": "http://192.168.99.100:7000/projects/f7072490-40bb-4f9f-a6ee-d79fcf783666",
    "project_url": "https://github-isl-01.ca.com/demouser/551D6EB0-C749-42B6-8CA0-EE955C3DD449",
    "service": "QubeFirstJavaProject",
    "version": "v2"
}
```
Note: Please be understand pushing images to registry and deployment to target endpoints are included in this demo

Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url) and follow the life cycle of the project.

## Bring your own repo, registry & target

### Install minikube

<a href="https://kubernetes.io/docs/getting-started-guides/minikube/" target="_new">Minikube</a> is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster inside a VM on your laptop for users looking to try out Kubernetes or develop with it day-to-day.

Obtain the script install_minikube.sh and minikube_registration_info.sh (TBD)

Make sure you have Virtual Box installed in your system.
```
$ ./install_minikube.sh
```

This will install Minikube on your system.
To verify that Minikube is installed:

```
  $ minikube status
  minikubeVM: Running
  localkube: Running
```

You can also verify that Minikube is running by checking your Virtual Box,  a VM named "minikube" will be created and started.


### Minikube info
```
$ ./minikube_registration_info.sh
Endpoint registration information:
==================================
Endpoint IP address   :  https://192.168.99.101:8443
Endpoint namespace    :  default
Endpoint default token:  xxxxxxxxxxxxxxxxxx
```
This information will be needed to create an 'target' endpoints in qubeship.

### Target Endpoint

The target endpoint is used to deploy your built project containers to the target environment (E.g. QA/Sandbox etc)

Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url)
1. Login to app with your github credentials
2. Open the Menu --> Opinions --> New
3. Enter the below details and save
```
Name: "Minikubesandbox"
URL: https://192.168.99.101:8443 (refer to above output value Endpoint IP address)
Type: Target
Provider: Kubernetes
AdditionalInfo:
{
    "namespace": "default" (refer to above output value Endpoint namespace)
}
Credential Type: Access Token
Token: xxxxxxxxxxx (refer to above output value Endpoint default token)
Enable checkbox [x] Set as default when adding projects
```

### Registry Endpoint

The registry endpoint is used to push your project image to this registry and can be later used to deploy target endpoint. 
Please <a href="https://hub.docker.com/" target="new">signup</a> with docker hub for an account. Use the docker hub login info to create registry endpoint in qubeship

Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url)
1. Login to app with your github credentials
2. Open the Menu --> Opinions --> New
3. Enter the below details and save
```
Name: "DockerHubRegistry"
URL: https://registry.hub.docker.com/
Type: Registry
Provider: Generic
AdditionalInfo:
{
    "account": "registry.hub.docker.com/{dockerhub-username}" (refer to above output value Endpoint namespace)
}
Credential Type: Username Password
UserName: {dockerhub-username}
Password: {dockerhub-password}
Enable checkbox [x] Set as default when adding projects
```


