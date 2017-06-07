# Install Qubeship Beta

## Prerequisites
1. Docker Toolbox [https://www.docker.com/products/docker-toolbox] which includes the following items:

   * Docker Runtime v1.11 and above
   * Docker-compose
   * Docker-machine
   
   ** **_Note_** **: Qubeship currently supports "Docker Toolbox" on macOS. "Docker for Mac" and Linux will be supported soon.

2. Text Editor
3. Curl [download from the official site](https://curl.haxx.se/download.html#MacOSX)
4. **_A valid and running Docker Host._**
   You should be able to run the following command and get a valid output:
```
    $ docker ps -a 
    CONTAINER ID        IMAGE                                                             COMMAND                  CREATED             STATUS                  PORTS                                                                      NAMES
```
5. Git client has to be installed on your machine. Run the below command to verify, you should see your Git version displayed back to you:
```
   $ git --version
   git version 2.11.0 (Apple Git-81)
```

6. Download the qubeship installation scripts, copy the following line into your terminal
```
$ git clone https://github.com/Qubeship/bootstrap && cd bootstrap && git checkout community_beta 
```

7. **Configuration** 
   * **Beta Users**: copy the **beta.config** file to qubeship_home/config  (** this file will be a part of Beta Welcome Kit email that you've received from Qubeship **)
   
   * **Community users**: create  scm.config file in qubeship_home/config. For instructions, please refer to: https://github.com/Qubeship/bootstrap/blob/master/OPEN_SOURCE_README.md
   
8. Register Qubeship with your GitHub account: run the below command for the automated script. 
<pre> 
$ ./register-qubeship.sh --username <i>github_username</i> --password [github_password] [--organization github_organization] [--github-host github_enterprise_url]
</pre>

Optional: you can use the <a href="https://github.com/Qubeship/bootstrap/blob/community_beta/README.md#github-configuration" target="_blank"> GitHub configuration manual steps </a> in case of an error.

9. The Internet connection: make sure that you can connect to the internet from within your corporate firewall. Qubeship uses Firebase, which requires internet connectivity.
----

## Install

1.  Run the install script
<pre>
$ ./install.sh --username <i>github_username</i> --password [github_password] [--organization github_organization] [--github-host github_enterprise_url]
</pre>

Note: if you are the **Github Enterprise** user, the argument <code>--github-host <i>github_enterprise_url</i></code> should be also passed to the script. Please refer to [Help](#help) for all available agruments.

At the end of installation, you should see a message like this:
```
Your Qubeship Installation is ready for use!!!!
Here are some useful urls!!!!
API: http://192.168.99.100:9080
You can use your GITHUB credentials to login !!!!
APP: http://192.168.99.100:7000
```

2. Login to Qubeship app using the URL showed in the message you see when done with the step 3.
```
You can use your GITHUB credentials to login !!!!
APP: http://192.168.99.100:7000
```


### Uninstall:
1. If your release has errors, simply run the following command from the Qubeship release directory:
```
   $ ./uninstall.sh
```
2. Restart the installation process

### Features:
1. Github.com / Github Enterprise
2. Registry support: Private Docker Registry, DockerHub, Quay.io
3. Deployment: Kubernetes, Minikube
4. Default out of the box toolchains for Python, Java, Gradle and Go
5. Default out of the box opinion for an end to end build, test and deploy
6. SonarQube

### Github Configuration (Optional)
Use the following instructions ONLY in case the automatic registration script fails.
There are three primary interfaces to Qubeship.
  * Qubeship GUI application - Qubeship user interface access
  * Qubeship CLI application - Qubeship command line access
  * Qubeship Builder - orchestrates the Qubeship workflow
 
Qubeship manages authentication for all three interfaces through Github OAuth. This allows for single sign-on 
through Github identity management. The first time you use Qubeship, register the above applications
as 0Auth applications in GitHub. You will only need to do this once. 
 
To configure  <a href="https://developer.github.com/apps/building-integrations/setting-up-and-registering-oauth-apps/registering-oauth-apps/" target="_blank">OAuth applications</a>, enter the following information in GitHub OAuth:


#### 1. Builder:  
```
    Client Name : qubeship-builder
    Home Page : https://qubeship.io
    Description : Qubeship Builder
    call back URL: http://<docker-machine-ip>:8080/securityRealm/finishLogin
```
Note: Run the below command to find the docker-machine IP. If you have multiple IPs, make sure to provide the correct one.
```
 docker-machine ip
 192.168.99.100
```
Copy and paste the client id and secret into the qubeship_home/config/scm.config 
in the variables **GITHUB_BUILDER_CLIENTID** and **GITHUB_BUILDER_SECRET**

#### 2. CLI: 
```
    Client Name : qubeship-cli
    Home Page : https://qubeship.io
    Description : Qubeship CLI client
    call back URL: http://cli.qubeship.io/index.html
```
Copy and paste the client id and secret into the qubeship_home/config/scm.config 
in the variables **GITHUB_CLI_CLIENTID** and **GITHUB_CLI_SECRET**

#### 3. APP:  
```
    Client Name : qubeship-app
    Home Page : https://qubeship.io
    Description : Qubeship GUI APP client
    call back URL:  http://<docker-machine-ip>:7000/api/v1/auth/callback?provider=github
```

Copy and paste the client id and secret into the qubeship_home/config/scm.config 
in the variables **GITHUB_GUI_CLIENTID** and **GITHUB_GUI_SECRET**

### Other Configuration Entries

#### 4. GITHUB_ENTERPRISE_HOST:
This is the Github entrerprise instance url to be used with qubeship. Qubeship will use this system as the defacto identity manager for Qubeship authentication , as well as use this for pulling the source code for builds. if this is left blank, the GITHUB_ENTERPRISE_HOST will be defaulted to https://github.com
Qubeship currently supports only http(s):// . SSH is in pipeline. 

```
GITHUB_ENTERPRISE_HOST  =   # no trailing slashes , only schema://hostname
```
#### 5. SYSTEM_GITHUB_ORG:  
This denotes the default system  organization for Qubeship. All users with membership to this org will be considered admin users for that Qubeship instance.   
![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/master/GithubORG.png)   

```
SYSTEM_GITHUB_ORG  =  #pick one from your list of organization as shown similar in above screenshot
```

### Config File Example

This is what an example config file looks like:
```
#optional - use only for onprem github : format : https://github_enterprise_host (no trailing slash)
GITHUB_ENTERPRISE_HOST= https://github_enterpise_url

# required
# Qubeship GUI client Authentication Realm
GITHUB_GUI_CLIENTID=32425453647567568768567868
GITHUB_GUI_SECRET=342534253245767867586476577
# Qubeship CLI client Authentication Realm
GITHUB_BUILDER_CLIENTID=5436453645754674567654
GITHUB_BUILDER_SECRET=75686756879867564353445
# Qubeship Builder Authentication Realm
GITHUB_CLI_CLIENTID=34645675647578867867857857
GITHUB_CLI_SECRET=3546543645756876868797897869
SYSTEM_GITHUB_ORG=yourorgname
```



### Help

1. ./install.sh --help
```
/install.sh --help
Usage: install.sh [-h|--help] [--verbose] [--username githubusername] [--password githubpassword]  [--organization orgname] [--github-host host ]
    --username                  github username
    --password                  github password. password can be provided in command line. if not, qubeship will prompt for password
    --organization              default github organization
    --github-host               github host [ format: http(s)://hostname ]
    --verbose                   verbose mode.
    --auto-pull                 automatic pull of docker images from qubeship

a. --organization :             the name of the Github organization of which Qubeship gives the admin access to every member. by default, Qubeship will give admin access to only you.
b. --github-host:               if is not supplied, Qubeship will default the SCM to https://github.com. it should only be of the pattern https://hostname.
                                DO NOT specify context path. Qubeship will automatically remove the trailing slashes if specified
```

### Post Install - viewing services deployed to Qubeship
You will need to take a few additional steps in order to view the services deployed via Qubeship. This is necessary because the local Kubernetes installation doesn't give access to the services over standard endpoints. As a one time setup effort, you have to run this from the bootsrap directory.
```
  qubeship_home/bin/kube-service-patch.sh
```
Step 1: determine your service name:
    this is the container prefix of your project
    `kubectl get services`
```
NAME                             CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
kubernetes                       10.0.0.1     <none>        443/TCP          3d
qubefirstpythonproject-service   10.0.0.63    <none>        443/TCP,80/TCP   2h
```

Step 2: use the access_qubeservice utilty to figure out your service URL  
```
qubeship_home/bin/access_qubeservice.sh qubefirstpythonproject-service /api
qubefirstjavaproject-service
IP address of the qubefirstjavaproject-service-service : 10.0.0.63 for api
curl http://10.0.0.63/api
{"api": "hello world"}
```   

Step 3: 
You're done! Now you can use Qubeship to import your first project from your repo.  [Use our handy web app to do this](http://qubeship.nickelled.com/welcome) or if you prefer, [use our command-line interface](http://qubeship.io/docs)


### FAQ:
1. How do I stop Qubeship services?

    In the bootstrap folder, do a: `./down.sh`
      
1. If the Qubeship services stop, how can I start them again?
      
    In the bootstrap folder, do a: `./run.sh`. Note: After the script has finished, it will take the Qubeship services a few minutes to further process before they become available.
      
    When Qubeship is ready, you'll be able to use the Swagger API at [http://192.168.99.100:9080](http://192.168.99.100:9080) and be able to access Qubeship itself at [http://192.168.99.100:7000](http://192.168.99.100:7000). Note: If this Qubeship URL does not show you any content, try logging out and in again.
      
1. I rebooted my machine and Qubeship stopped working, what should I do?

    The best way to avoid this problem is to "Save State" in the VirtualBox before rebooting and then "start" the VM again.

    If you didn't do this, here are some more options:
      
    * Open VirtualBox and make sure the "default" VM is running. If not, "start" it.
    * Make sure the VM has finished booting and is showing you a terminal UI.
    * In the bootstrap folder, do a: `./run.sh` to restart Qubeship's services.

1. I tried installing Qubeship, but the script is giving me an error. What's wrong?

    <pre>exec: "Docker-credential-osxkeychain": executable file not found in $PATH out: ``</pre>

    It sounds like your docker config file is slightly misconfigured. 
    This can happen if you’ve converted from Docker for Mac to Docker Toolbox,  
    or similar nonstandard situations. Your system thinks that your credentials are being stored on an  
    external credentials store such as native keychain of operating system (which is good,  
    as it’s typically much more secure than storing it in a docker configuration file),
    but it lacks the actual docker-credential-osxkeychain executable to make the connection. 
    You can confirm this by looking in your ~/.docker/config.json file for
    “credsStore”: “osxkeychain”

    If you see it, then you’ve got confirmation. To fix this, you have two options:

    a. Install the docker-credential-osxkeychain: 
    You need to go to https://github.com/docker/docker-credential-helpers/releases,
    find the Release version marked ‘Latest release’ (probably the top block), and then click 
    docker-credential-osxkeychain-v#.#.#-#####.tar.gz’ where ‘#.#.#’ is the release number.
    Unzip the downloaded file, and then put the resulting ‘docker-credential-osxkeychain’
    executable file into your /usr/local/bin directory (user's local bin). Now uninstall and 
    then reinstall Qubeship.

    --- or ---

    b. Tell your system you want to store your credentials locally:
    Simply remove the “credsStore”: “osxkeychain” from ~/.docker/config.json and then uninstall 
    and reinstall Qubeship. Easy, but less secure.

    Again, we highly recommend that you try for option ‘a’ as it’s definitely the most secure way to go.

1. Installation failed due to the login failure.

    1. If the error message was:
    
        <pre>Error response from daemon: Get https://quay.io/v2/: unauthorized: Could not find robot with username: qubeship+test and supplied password.</pre>

       Open the `qubeship_home/config/beta.config` with Vim in binary mode:  
       `vim -b qubeship_home/config/beta.config`  
       and make sure the file DOES NOT have ANY trailing `^M` characters.

    1. If the error message was:

        <pre>Get https://registry-1.docker.io/v2/library/ruby/manifests/2.3: unauthorized: incorrect username or password</pre>

       Run  
       `set -o allexport; source qubeship_home/config/beta.config; docker login -u $BETA_ACCESS_USERNAME -p $BETA_ACCESS_TOKEN quay.io`  
       to see if the command works. If not, backup the existing docker config.json file, delete it, and re-run the command:
       
       <pre>mv ~/.docker/config.json ~/.docker/config.json.bck</pre>

1. How do I install using Github Enterprise?
   
1. How to install Qubeship with Kubernetes?

1. How to install Qubeship with a default Docker registry?
   
1. How can I view services deployed by Qubeship to Minikube? 
