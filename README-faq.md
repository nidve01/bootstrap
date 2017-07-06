## FAQ:
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

