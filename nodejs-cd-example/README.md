# NodeJS Example App Continuous Deployment

## NodeJS App Example Initial Deployment

Firstly, an application running is required in order implement its continuous deployment and a couple of projects in Openshift. For this reason, it is required to complete the following steps:

-   Create Openshift projects

```
$ oc login -u user -p password https://console-openshift-console.example.com
$ oc new-project nodejs-app-example
$ oc new-project nodejs-app-example-cicd
```

-   Download NodeJS App Example Repository

```
$ git clone https://github.com/acidonper/nodejs-app-example.git
```

-   Deploy the application in Openshift (Please, visit [NodeJS App Example Repository](https://github.com/acidonper/nodejs-app-example) and Please, visit [Deploy NodeJS App Example in Openshift ](./.openshift/README.md) for more information about App deployment in Openshift.
    for more information)

```
$ cd nodejs-app-example/.openshift
$ sh openshift-nodejs-app-example.sh projectexample01
```

## Implementation Steps

From an general point of view, a complete Tekton automated procedure required to have involved the following objects:

-   Git Repository Service Account with repository credentials (\*Private repositories only)
-

```
$ oc create -f 00-GitHub-Secret_ServiceAccount.yaml
```

### Create Pipeline Resources

```
$ oc create -f 01-linking_app-inputs-PipelineResource.yaml
$ oc create -f 02-linking_app-outputs-PipelineResource.yaml
```

## Clean Tekton resource

The following procedures illustrates how multiple Tekton resources can be deleted by only one shoot:

-   Delete Pipeline Resources

```
$ tkn resource list | grep -v NAME | awk '{print "tkn resource delete "$1 " -f"}'| sh
```

-   Delete Tasks

```
$ tkn task list | grep -v NAME | awk '{print "tkn task delete "$1 " -f"}'| sh
```

-   Delete Pipelines

```
$ tkn pipeline list | grep -v NAME | awk '{print "tkn pipeline delete "$1 " -f"}'| sh
```

-   Delete Pipeline Runs

```
$ tkn pipelinerun list | grep -v NAME | awk '{print "tkn pipelinerun delete "$1 " -f"}'| sh
```

```
$ oc process -f nodejs-app-tekton-cicd.yaml -p APP_NAME=linking-app-images APP_NAMESPACE=linking-app GIT_PASSWORD=****** GIT_USERNAME=****** APP_NAME_BC=linking-app-images APP_NAME_DC=linking-app-images | oc create -f -

$ curl -X POST -H "Content-Type: application/json" -d '{"head_commit":{"id":"a652fb8b9aaba941707ae5e5701c0b7eea5bc7af"},"repository":{"name":"linking-app-images","url":"https://github.com/acidonper/linking-app-images.git"}}' http://el-linking-app-nctad-http-linking-app-cicd.apps-crc.testing
{"eventListener":"eventlistener-linking-app-images-new-commit-test-and-deploy","namespace":"images-cicd","eventID":"ws2rx"}

```
