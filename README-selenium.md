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



# Configuring qube.yaml


# Configuring Toolchain manifest


# Test output


