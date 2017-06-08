# Post Install Qubeship Beta

## Basic Capabilities Demo 

Running the following creates sample projects for you to demo Qubeship capabilities. You will be able to monitor the builds of those projects with a basic opinion (build only).

```
$ ./demo-basic-builds.sh
creating sample python project
{
    "id": "5934354368e4c1c1001f054f3d",
    "project_id": "c66e99f5-28b6-47f7-9170-1f93b655102b",
    "project_location": "http://192.168.99.100:7000/projects/c66e99f5-28b6-47f7-9170-1f93b655102b",
    "project_url": "https://github-isl-01.ca.com/demouser/008435AD-0C10-42A9-A09E-07C7E4CB8800",
    "service": "QubeFirstPythonProject",
    "version": "v2"
}
creating sample java project
{
    "id": "59374f75e4c1c1001f054f3e",
    "project_id": "f7072490-40bb-4f9f-a6ee-d79fcf783666",
    "project_location": "http://192.168.99.100:7000/projects/f7072490-40bb-4f9f-a6ee-d79fcf783666",
    "project_url": "https://github-isl-01.ca.com/demouser/551D6EB0-C749-42B6-8CA0-EE955C3DD449",
    "service": "QubeFirstJavaProject",
    "version": "v2"
}
```
Note: This basic demo does not includes pushing images to registry and deploying to target endpoints.

Now open the Qubeship app http://192.168.99.100:7000 (please refer to the installation success message for your APP URL, as it may differ from the shown default) and follow the project build.

## Bring your own repo, registry & target

### Install Minikube (Do this if you will need to create a target endpoint for your deployments)

<a href="https://kubernetes.io/docs/getting-started-guides/minikube/" target="_new">Minikube</a> is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster inside a VM on your laptop. It is suitable both for users looking to try out Kubernetes and to develop with it day-to-day.

Make sure that you have Virtual Box installed on your system. Run the below command to install Minikube:
```
$ ./install_minikube.sh
```
Run the following command to verify that Minikube is succesfully installed:

```
  $ minikube status
  minikubeVM: Running
  localkube: Running
```

You can (optionally) verify that Minikube is running in your Virtual Box: see if a VM named "minikube" has been created and started.

Run the below command to see the information about your Minikube environment. You will need this information to create 'target' endpoints in Qubeship:
```
$ ./minikube_registration_info.sh
Endpoint registration information:
==================================
Endpoint IP address   :  https://192.168.99.101:8443
Endpoint namespace    :  default
Endpoint default token:  xxxxxxxxxxxxxxxxxx
```

#### Create Your Target Endpoint

The target endpoint is used to deploy your built project containers to the target environment (Ex: QA, Sandbox, etc.)

Open the qubeship app http://192.168.99.100:7000 (please refer to the installation success message for your APP URL, as it may differ from the shown default)
1. Login to app with your GitHub credentials
2. Open the left navigation menu --> Endpoints --> + (Add Endpoint)
3. Enter the below details and save:
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
The registry endpoint is used to push your project image to this registry; it can be later used as a deployment target endpoint. 

Please <a href="https://hub.docker.com/" target="new">signup</a> with Docker Hub for an account, then use the Docker Hub login info to create your registry endpoint in Qubeship.

#### Create Your Registry Endpoint

Open the qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP url)
1. Login to app with your GitHub credentials
2. Open the left navigation menu --> Endpoints --> + (Add Endpoint)
3. Enter the below details and save:
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

### Configure Your Project
Open the qubeship app http://192.168.99.100:7000 (please refer to the installation success message for your APP URL, as it may differ from the shown default)
1. Log into the app with your GitHub credentials
2. Open the left navigation menu --> Project --> + (Add Project)
3. Enter the below details and save:
```
Project Name: "YourProjectName"
Repo URL: https://github-enterpise.com/yourusername/yourprojectname
Repo Branch: (enter your branch name)
Language: (select Java or Python)
Show Advanced Options v
Opinion: Qubeship build-bake-deploy opinion
Toolchain: (you may leave this blank (default toolchain will be assigned))
Endpoint: MinikubeSandbox
```
Note: 
1. Your project has to have a Dockerfile to build successfully in Qubeship
2. If your project needs more advanced tools, you may need to <a href="https://qubeship.io/docs/toolchains-ui/">create a new toolchain.</a>
3. If your project uses any custom scripts, you may have to modify the opinion (and/or) toolchain manifest.

Now open the Qubeship app http://192.168.99.100:7000 (refer to the installation success message for APP URL) and follow the the project build.

Once your project is successfully built, you may verify the following:
1. Check if your project image has been pushed to your <a href="https://hub.docker.com/" target="new">Docker Hub account</a>
2. Run the below commands to verify pods and service running in your Minikube cluster: 
```
$ /usr/local/bin/kubectl get services
mycustomproject-service   10.0.0.247   <none>        443/TCP,80/TCP   2m
```
```
$ /usr/local/bin/kubectl get pods
mycustomproject-deployment-3538093953-jw22t   1/1       Running   0          1m
```

You are done! Your new project container is now deployed to your Minikube sandbox environment.
