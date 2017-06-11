# Install Qubeship Beta

## Prerequisites
1. Download and install <a href="https://www.docker.com/products/docker-toolbox">**Docker Toolbox**</a> which includes the following items:

   * Docker Runtime v1.11 and above
   * Docker-compose
   * Docker-machine
   
   ** **Note**: Qubeship currently supports "Docker Toolbox" only on MacOS. "Docker for Mac" and Linux will be supported soon.

2. **Text Editor**
3. **Curl** [download from the official site](https://curl.haxx.se/download.html#MacOSX)
4. **_A valid and running Docker Host._**
   You should be able to run the following command and get a valid output:
```
    mac1234:~ user$ docker ps -a 
    CONTAINER ID        IMAGE                                                             COMMAND                  CREATED             STATUS                  PORTS                                                                      NAMES
```
5. Install **Git client** on your machine. Run the below command to verify that you have it, you should see your Git version displayed back to you:
```
   mac1234:~ user$ git --version
   git version 2.11.0 (Apple Git-81)
```
6. Have your **github enterprise url**, **username** & **password** handy. You also need an active connection to your corporate network. You will provide them in step nine and Install-Step 1.

```
   mac1234:~ user$ curl -k -I {your_github_enterprise_url} | grep HTTP/1.1
   HTTP/1.1 200 OK (or)
   HTTP/1.1 302 Found
```

7. To **download Qubeship installation scripts**, copy the following line into your terminal:
```
mac1234:~ user$ cd ~
mac1234:~ user$ git clone https://github.com/Qubeship/bootstrap && cd bootstrap && git checkout community_beta 
mac1234:bootstrap username$ pwd
~/bootstrap
```

8. **Configuration**: copy the **beta.config** file to ~/bootstrap/qubeship_home/config  (** this file will be a part of Beta Welcome Kit email that you've received from Qubeship **)
   
   
9. **Register Qubeship** with your GitHub account: run the following command from **bootstrap** folder to automate the registration. 
<pre> 
mac1234:bootstrap user$ ./register-qubeship.sh --username <i>your_github_username</i> --password --github-host your_github_enterprise_url
</pre>

**Note**: **Github Enterprise** users, connect to VPN and supply the argument <code>--github-host <i>your_github_enterprise_url</i></code> Please refer to [Help](#help) for all other available agruments.

**Optional**: you can use the <a href="https://github.com/Qubeship/bootstrap/blob/community_beta/README-githubconfiguration.md" target="_blank"> Register Qubeship manual steps </a> in case of any errors with register-qubeship.sh script.

10. **The Internet Connection:** make sure that you can connect to the internet from within your corporate firewall. Qubeship uses Firebase, which requires internet connectivity.
----

## Install

1.  **Run** the install script from **bootstrap** folder
<pre>
mac1234:bootstrap user$ ./install.sh --username <i>your_github_username</i> --password --github-host <i>your_github_enterprise_url</i>
</pre>

Note: if you are the **Github Enterprise** user, the argument <code>--github-host <i>github_enterprise_url</i></code> should be github enterprise url. Please refer to [Help](#help) for all other available arguments.

At the end of installation, you should see a message like this:
```
==================================================
Your Qubeship Installation is ready for use!!!!
Here are some useful urls!!!!
API: http://192.168.99.100:9080
You can use your GITHUB credentials to login !!!!
APP: http://192.168.99.100:7000
===================================================
```

2. **Login** to Qubeship app using the URL showed in the message shown above.
```
You can use your GITHUB credentials to login !!!!
APP: http://192.168.99.100:7000
```
----
## Post Install
Congratulations, you have successfully installed Qubeship!

Now, it is time to try qubeship. Please follow the <a href="https://github.com/Qubeship/bootstrap/blob/community_beta/README-postInstall.md"> post install instructions </a>

----

## Uninstall:
1. To uninstall, run the following command from the Qubeship release directory:
```
mac1234:bootstrap user$ ./uninstall.sh
```
2. Restart the <a href="https://github.com/Qubeship/bootstrap/blob/community_beta/README.md#install" target="_blank">installation process
----
## Help

1. ./install.sh --help
```
/install.sh --help
Usage: install.sh [-h|--help] [--verbose] --username githubusername --password [githubpassword] [--github-host host] [--organization orgname]
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
----
## Features:
1. Github.com / Github Enterprise
2. Registry support: Private Docker Registry, DockerHub, Quay.io
3. Deployment: Kubernetes, Minikube
4. Default out of the box toolchains for Python, Java, Gradle and Go
5. Default out of the box opinion for an end to end build, test and deploy

----

##  <a href="https://github.com/Qubeship/bootstrap/blob/community_beta/README-faq.md">FAQ</a>
