# Performing functional test using Selenium

To execute user interface functipnal test with Selenium, you will need to have:

1) Selenium server or Selenium grid available for access from Quebship build containers.
2) Accessible target endpoints addresss
3) Selenium test cases that could be configured with the address to the target endpoind and Selenium server/grid endpoint.


# Exposing endpoints

Target endpoints needs to ba accessible from Qubeship testing container for the UI functional test  to execute.

For Kubernetes, this can be done either by:

(1) assigning an external IP to the service
(2) adding the app as part of the ingress service.


# Configuring opinion.yaml

Specify an opinion for the functional test execution.  This done at the stage go deploy_to_qa or deploy_to_prod.
eg:

<pre>
  deploy_to_prod:
    has:
      - release_to_prod
      - wait_for_service_ready
      - functional_test
</pre>

<pre>
  functional_test:
    skippable: false
    execute_outside_toolchain: false
</pre>


# Configuring Toolchain manifest
You can then specify the actions (command, scripts,..) to be executed for triggering functional test in your manifest.

From the example above, the 

<code>
  deploy_to_prod.functional_test: "run_ui_func_test.sh $@"
</code>


# Configuring qube.yaml
If you are specifying the functional test actions in your Toolchain manifest, you can specify the arguments to te manifest command in your qube.yaml

In the example below, qube.yaml is passing the argument "url=http://myjavahost" and "seleniumGridUrl=http://192.168.99.101:32768/wd/hub" as parameter to the functional test triggering script specified in the Toolchain manifest.

<pre>
deploy_to_prod:
  skip: false
  functional_test:
    publish:
    - target
    - target/surefire-reports/index.html
    args:
    - -Pfunctional-tests
    - -Durl=http://myjavahost
    - -DseleniumGridUrl=http://192.168.99.101:32768/wd/hub
    execute_outside_toolchain: false
</pre>


If you do not want to modify the manifest file with the functional test execution details, you can specify everythign related to the functional test execution triggering in your qube.yaml

In the example below, the functional test execution is executed by "pip install -r requirements.txt" and "/home/app/run_ui_func_test.sh http://10.137.175.76:4444/wd/hub http://myjavahost/static/home.html"  where the target application and Selenium server or grid have been specified.

<pre>
deploy_to_prod:
  skip: false
  functional_test:
    actions:
    - pip install -r requirements.txt
    - /home/app/run_ui_func_test.sh http://10.137.175.76:4444/wd/hub http://myjavahost/static/home.html
    publish:
    - dist
    - dist/PyPetUITestReport.html
    execute_outside_toolchain: false
</pre>


# Test output

To view the result for your functional tests in Qubeship, you need to dump the output of your test at a particular location in your project directory structure and specify the path of that location in your qube.yaml

In the above example, the output is written into <projectroot>/dist directory as a file called "PyPetUITestReport.html", and the qube.yaml is configured as such.

<pre>
    publish:
    - dist
    - dist/PyPetUITestReport.html
</pre>



