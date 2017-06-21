# Post Install Qubeship Beta

## Basic Capabilities Demo 

Running the following creates sample projects for you to demo Qubeship capabilities. You will be able to monitor the builds of those projects with a basic opinion (build only).

```
$ ./demo-basic-builds.sh
creating a sample Python project:
{
    "id": "5934354368e4c1c1001f054f3d",
    "project_id": "c66e99f5-28b6-47f7-9170-1f93b655102b",
    "project_location": "http://192.168.99.100:7000/projects/c66e99f5-28b6-47f7-9170-1f93b655102b",
    "project_url": "https://github-isl-01.ca.com/demouser/008435AD-0C10-42A9-A09E-07C7E4CB8800",
    "service": "QubeFirstPythonProject",
    "version": "v2"
}
creating a sample Java project:
{
    "id": "59374f75e4c1c1001f054f3e",
    "project_id": "f7072490-40bb-4f9f-a6ee-d79fcf783666",
    "project_location": "http://192.168.99.100:7000/projects/f7072490-40bb-4f9f-a6ee-d79fcf783666",
    "project_url": "https://github-isl-01.ca.com/demouser/551D6EB0-C749-42B6-8CA0-EE955C3DD449",
    "service": "QubeFirstJavaProject",
    "version": "v2"
}
```
Note: This basic demo does not includes pushing images to a registry and deploying to target endpoints.

Now open the Qubeship app http://192.168.99.100:7000 (please refer to the installation success message for your APP URL, as it may differ from the shown default) and follow the project build.

## Bring Over Your Repo, Registry & Target

### Install Minikube (Do this if you will need a new target endpoint for your deployments)

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

### Set up Registry
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

#### Exposing your target endpoint via ingress

For your target endpoint to be accessible from outside of Minikube containers, you need to to expose the endpoints using minikube's ingress.

##### 1. Setup mininkube ingress service

<code>
minikube addons enable ingress
</code>

##### 2. Provide domain name to the minikube's IP address

For ingress connection and routing to be resolved, URL to the service needs to made using a domain name instead of IP address.
One way to do it for the deployment above is to configure the /etc/hosts file, adding entry that maps a name to the minikube's IP address.

In the example below, the Minikube's IP address "192.168.99.101" is associated to the name "myinghost".

<pre>
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost
192.168.99.101  myinghost
</pre>


##### 3. Create a setup file for the ingress creation

Create a yaml file with the configuration for the ingress to be created.

The example below creates an ingress called "pypet-ingress", that is served by host "myinghost" of which the root path will map to "pypet-service" listening on port 80.

<pre>
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pypet-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  backend:
    serviceName: default-http-backend
    servicePort: 80
  rules:
  - host: myinghost
    http:
      paths:
      - path: /
        backend:
          serviceName: pypet-service
          servicePort: 80
</pre>


##### 4. Create the ingress

Execute the following command and supplying the yaml setup file that you created from the previous step.

<code>
    kubectl create -f <yaml setup file>
</code>

##### 5. Check that ingress is created

Exceute the command <code> kubectl get ingress </code> to see the status of the ingress that you have created.

<pre>
NAME            HOSTS        ADDRESS          PORTS     AGE
pypet-ingress   myinghost    192.168.99.102   80        30s
</pre>

If the ADDRESS has received an IP value, the ingress service should be ready.


##### 6. Accessing the your service

If your ingress has been created and has an IP address;  and your service is up and running, your ingress service will be ready to take requests from clients outside of Minikube's container.

To access the ingress,  use the the URL path with the same hostname defined in (2) and used in yaml file in (3)

In the above example, "pypet-service" can be accessed with the following URL: <code> http://myinghost/ </code>


