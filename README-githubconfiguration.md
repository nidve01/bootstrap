# Github Configuration
**Note**: The following instructions are optional. Use those ONLY in case the automatic registration script fails.

There are three primary interfaces to Qubeship.
  * Qubeship GUI application - Qubeship user interface access
  * Qubeship CLI application - Qubeship command line access
  * Qubeship Builder - orchestrates the Qubeship workflow
 
Qubeship manages authentication for all three interfaces through Github OAuth. This allows for single sign-on 
through Github identity management. The first time you use Qubeship, register the above applications
as 0Auth applications in GitHub. You will only need to do this once. 

![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/community_beta/beforeauthsetup.png)
 
To configure  <a href="https://developer.github.com/apps/building-integrations/setting-up-and-registering-oauth-apps/registering-oauth-apps/" target="_blank">OAuth applications</a>, enter the following information in GitHub OAuth:


#### 1. Builder:  
```
    Client Name : qubeship-builder
    Home Page : https://qubeship.io
    Description : Qubeship Builder
    call back URL: http://<docker-machine-ip>:8080/securityRealm/finishLogin
```

![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/community_beta/oauthbuilder.png)   
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
![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/community_beta/oauthcli.png)   

Copy and paste the client id and secret into the qubeship_home/config/scm.config 
in the variables **GITHUB_CLI_CLIENTID** and **GITHUB_CLI_SECRET**

#### 3. APP:  
```
    Client Name : qubeship-app
    Home Page : https://qubeship.io
    Description : Qubeship GUI APP client
    call back URL:  http://<docker-machine-ip>:7000/api/v1/auth/callback?provider=github
```
![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/community_beta/oauthapp.png)  

Copy and paste the client id and secret into the qubeship_home/config/scm.config 
in the variables **GITHUB_GUI_CLIENTID** and **GITHUB_GUI_SECRET**

If you have something like this, you have successfully registered the oauth applications

![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/community_beta/afteroauthsetup.png)

### Other Configuration Entries

#### 4. GITHUB_ENTERPRISE_HOST:
This is the Github entrerprise instance url to be used with qubeship. Qubeship will use this system as the defacto identity manager for Qubeship authentication , as well as use this for pulling the source code for builds. if this is left blank, the GITHUB_ENTERPRISE_HOST will be defaulted to https://github.com
Qubeship currently supports only http(s):// . SSH is in pipeline. 

```
GITHUB_ENTERPRISE_HOST  =   # no trailing slashes , only schema://hostname
```
#### 5. SYSTEM_GITHUB_ORG:  
This denotes the default system  organization for Qubeship. All users with membership to this org will be considered admin users for that Qubeship instance. 

![Example](https://raw.githubusercontent.com/Qubeship/bootstrap/community_beta/githuborg.png)    

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
You are good to go, go back to your <a href="https://github.com/Qubeship/bootstrap/blob/community_beta/README.md#install"/> installation instructions </a> and proceed now

----
