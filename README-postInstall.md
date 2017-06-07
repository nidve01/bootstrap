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
Note: The basic demo does not includes pushing images to registry and deploying to target endpoints.

Now open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP URL) and follow the life cycle of the project build.

## Bring your own repo, registry & target

### Install minikube (target)

<a href="https://kubernetes.io/docs/getting-started-guides/minikube/" target="_new">Minikube</a> is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster inside a VM on your laptop for users looking to try out Kubernetes or develop with it day-to-day.

Make sure you have Virtual Box installed in your system. Run the below command to install Minikube on your system.
```
$ ./install_minikube.sh
```
Run below to verify  minikube is succesfully installed

```
  $ minikube status
  minikubeVM: Running
  localkube: Running
```

You can optionally verify minikube is running in your Virtual Box,  a VM named "minikube" will be created and started.

Run the below command to see the information about your minikube environment, this will needed to create 'target' endpoints in qubeship
```
$ ./minikube_registration_info.sh
Endpoint registration information:
==================================
Endpoint IP address   :  https://192.168.99.101:8443
Endpoint namespace    :  default
Endpoint default token:  xxxxxxxxxxxxxxxxxx
```

#### Target Endpoint

The target endpoint is used to deploy your built project containers to the target environment (E.g. QA/Sandbox etc)

Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url)
1. Login to app with your github credentials
2. Open the Menu --> Endpoints --> New
3. Enter the below details and save
```
Name: "MinikubeSandbox"
URL: https://xxx.xxx.xx.xxx:xxxx (refer to minikube_registration_info.sh console output for 'Endpoint IP address')
Type: Target
Provider: Kubernetes
AdditionalInfo:
{
    "namespace": "xxxxx" (refer to minikube_registration_info.sh console output for 'Endpoint namespace')
}
Credential Type: Access Token
Token: xxxxxxxxxxx (refer to minikube_registration_info.sh console output for 'Endpoint default token')
Enable checkbox [x] Set as default when adding projects
```

### Registry
The registry endpoint is used to push your project image to this registry and can be later used to deploy target endpoint. 

Please <a href="https://hub.docker.com/" target="new">signup</a> with docker hub for an account. Use the docker hub login info to create registry endpoint in qubeship

#### Registry Endpoint

Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url)
1. Login to app with your github credentials
2. Open the Menu --> Endpoints --> New
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

### Configure project
Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url)
1. Login to app with your github credentials
2. Open the Menu --> Project --> New
3. Enter the below details and save

Note: You may user your qubeship qualified project to configured below
```
Project Name: "MyCustomProject"
Repo URL: https://github-enterpise.com/demouser/mycustomproject
Repo Branch: master
Language: java/python
Show Advanced Option v
Opinion: Qubeship build-bake-deploy opinion
Toolchain: you may leave blank (default toolchain will be assigned)
Endpoint: MinikubeSandbox
```
Note: 
1. If your project needs more advanced tools you may have to <a href="https://qubeship.io/docs/toolchains-ui/">create a new toolchain</a>
2. If your project use any custom scripts, you may have to modify the opinion (and/or) toolchain manifest

Now open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP URL) and follow the life cycle of the project build.

Once your project is successfully built, you may verify the below things
1. Your project image being pushed to your <a href="https://hub.docker.com/" target="new">docker hub account</a>
2. Run the below commands to verify pods and service running in your minikube cluster with below
```
$ /usr/local/bin/kubectl get services
mycustomproject-service   10.0.0.247   <none>        443/TCP,80/TCP   2m
```
```
$ /usr/local/bin/kubectl get pods
mycustomproject-deployment-3538093953-jw22t   1/1       Running   0          1m
```
