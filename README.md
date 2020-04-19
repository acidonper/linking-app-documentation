# Linking App CI/CD

Linking App CI/CD is a repository which tries to collect information regarding Continuous Integration and Deployment in Linking App microservices. As a summary, it is important to bear in mind that the following repositories compose Linking App application:

-   [Chat](https://github.com/acidonper/linking-app-chat.git) -> _Linking App Chat_ is a NodeJS project which provides a Chat tool in order to allow _Linking App Front_ users a way of communication with each other.
-   [Images](https://github.com/acidonper/linking-app-images.git) -> _Linking App Images_ is a NodeJS project which provides an API in order to allow _Linking App Front_ users manage their photographs.
-   [Back](https://github.com/acidonper/linking-app-back.git) -> _Linking App Back_ is a NodeJS project which provides an API in order to allow _Linking App Front_ users access to some Linking App information.
-   [Front](https://github.com/acidonper/linking-app-front.git) -> _Linking App Front_ is a React project, written in Typescript, which provides a new way of meet people to the users though an amazing Web Interface.

As it is possible to see in each microservice repository, an Openshift templates has been developed in order to facilitate the microservice deployment in Openshift. It is important to bear in mind that this procedure are located in a folder name `.openshift` in each microservice repository.

**IMPORTANT: It is required to have these microservices deployed before the Continuous Deployment procedures integration. Please, visit each microservice repository documentation in order to deploy them before continuing with this document.**

## Automation Mechanism (Tekton)

Continuous Integration and Deployment in Linking App microservices have an important mission, they are responsible for each Linking App repository change registration. In addition, each repository modification triggers a specific automated procedure in order to promote this change to Linking App production environment.

Tekton is the automation tool which implements these automated procedures. As their web page informs, Tekton is a powerful and flexible open-source framework for creating CI/CD systems, allowing developers to build, test, and deploy across cloud providers and on-premise systems (Kubernetes, serverless, VMs, etc) by abstracting away the underlying details. Please, visit [Tekton - OpenShift Pipelines](./docs/tekton.md) for more information about this tool.

### Prerequisites

Firstly, linking app microservices must be running in an openshift project (For example `linking-app`) in order implement its continuous deployment procedure. Once microservices are deployed, it is required to complete the following steps:

-   Check Linking App Microservices Pods are running properly

```
$ oc get pods -n linking-app
NAME                         READY   STATUS    RESTARTS   AGE
linking-app-back-1-7lvz5     1/1     Running   3          4d9h
linking-app-chat-9-25ckj     1/1     Running   2          3d5h
linking-app-front-1-796ck    1/1     Running   3          4d9h
linking-app-images-1-dtzwk   1/1     Running   2          4d10h
mongodb-1-gtkrf              1/1     Running   2          4d9h
```

-   Check ImageStreams microservices revisions

```
$ oc get is -n nodejs-app-example
NAME                 IMAGE REPOSITORY                                                                        TAGS     UPDATED
linking-app-back     default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-back     latest   4 days ago
linking-app-chat     default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-chat     latest   3 days ago
linking-app-front    default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-front    latest   4 days ago
linking-app-images   default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-images   latest   4 days ago
```

-   Check Front microservice works properly

```
$ oc get route -n linking-app
NAME                      HOST/PORT                                             PATH   SERVICES             PORT                      TERMINATION     WILDCARD
...
linking-app-front         linking-app-front-linking-app.apps-crc.testing                linking-app-front    linking-app-front-http    edge/Redirect   None

$ curl -k https://linking-app-front-linking-app.apps-crc.testing
```

### Continuous Deployment procedure implementation (Tekton)

The following section tries to give continuous deployment workflow implementation in Openshift based on Tekton for each Linking App microservice. From a general point of view, in a complete CD Tekton automated procedure will be necessary to have involved the following objects:

-   A service account to generate Tekton objects automatically (\*Created by default -> "pipeline")
-   A service account to save GitHub credentials in order to pull repositories code
-   A service account responsible for start new app builds and deployments
-   A set of task to implement application test and perform app builds/deployments
-   A pipeline to group and organize tasks
-   A Trigger Template which links pipelines to the dynamic resources (git repository based on a specific commit/push)
-   A Trigger Binding which captures events parameters (git commit ID)
-   An Event listener to capture commits/push events from the repository and trigger Tekton automatized procedure

In order to create these resources from an easy way, a template will be applied for each microservice. Please, follow next steps in order to create these Tekton objects automatically:

-   Create Openshift CI/CD project

```
$ oc new-project linking-app-cicd
```

-   Create CD automated process per each microservice

```
$ oc process -f linking-app-tekton-cicd.yaml -p APP_NAME=linking-app-chat APP_NAME_BC=linking-app-chat APP_NAME_DC=linking-app-chat APP_NAMESPACE=linking-app -p GIT_USERNAME=***** -p GIT_PASSWORD==***** | oc apply -f -
$ oc process -f linking-app-tekton-cicd.yaml -p APP_NAME=linking-app-images APP_NAME_BC=linking-app-images APP_NAME_DC=linking-app-images APP_NAMESPACE=linking-app -p GIT_USERNAME=***** -p GIT_PASSWORD==***** | oc apply -f -
$ oc process -f linking-app-tekton-cicd.yaml -p APP_NAME=linking-app-back APP_NAME_BC=linking-app-back APP_NAME_DC=linking-app-back APP_NAMESPACE=linking-app -p GIT_USERNAME=***** -p GIT_PASSWORD==***** | oc apply -f -
$ oc process -f linking-app-tekton-cicd.yaml -p APP_NAME=linking-app-front APP_NAME_BC=linking-app-front APP_NAME_DC=linking-app-front APP_NAMESPACE=linking-app -p GIT_USERNAME=***** -p GIT_PASSWORD==***** | oc apply -f -
```

#### Check Tekton Objects

The previous templates would have added some new tekton objects in `linking-app-cicd` project. In order to be check these new objects, it is required to follow the procedure included in this section:

```
$ sh utils/tekton-list-object.sh

EvenListeners:
NAME                                                          AGE
eventlistener-linking-app-back-new-commit-test-and-deploy     28 seconds ago
eventlistener-linking-app-chat-new-commit-test-and-deploy     4 minutes ago
eventlistener-linking-app-front-new-commit-test-and-deploy    12 seconds ago
eventlistener-linking-app-images-new-commit-test-and-deploy   1 minute ago
***

TriggerBindings:
NAME                                                           AGE
triggerbinding-linking-app-back-new-commit-test-and-deploy     28 seconds ago
triggerbinding-linking-app-chat-new-commit-test-and-deploy     4 minutes ago
triggerbinding-linking-app-front-new-commit-test-and-deploy    12 seconds ago
triggerbinding-linking-app-images-new-commit-test-and-deploy   1 minute ago
***

TriggerTemaples:
NAME                                                            AGE
triggertemplate-linking-app-back-new-commit-test-and-deploy     28 seconds ago
triggertemplate-linking-app-chat-new-commit-test-and-deploy     4 minutes ago
triggertemplate-linking-app-front-new-commit-test-and-deploy    12 seconds ago
triggertemplate-linking-app-images-new-commit-test-and-deploy   1 minute ago
***

Pipelines:
NAME                                                     AGE              LAST RUN   STARTED   DURATION   STATUS
pipeline-linking-app-back-new-commit-test-and-deploy     28 seconds ago   ---        ---       ---        ---
pipeline-linking-app-chat-new-commit-test-and-deploy     4 minutes ago    ---        ---       ---        ---
pipeline-linking-app-front-new-commit-test-and-deploy    12 seconds ago   ---        ---       ---        ---
pipeline-linking-app-images-new-commit-test-and-deploy   1 minute ago     ---        ---       ---        ---
***

Tasks:
NAME                                             AGE
task-linking-app-back-new-commit-deploy-app      28 seconds ago
task-linking-app-back-new-commit-start-build     28 seconds ago
task-linking-app-back-new-commit-test            28 seconds ago
task-linking-app-chat-new-commit-deploy-app      4 minutes ago
task-linking-app-chat-new-commit-start-build     4 minutes ago
task-linking-app-chat-new-commit-test            4 minutes ago
task-linking-app-front-new-commit-deploy-app     12 seconds ago
task-linking-app-front-new-commit-start-build    12 seconds ago
task-linking-app-front-new-commit-test           13 seconds ago
task-linking-app-images-new-commit-deploy-app    1 minute ago
task-linking-app-images-new-commit-start-build   1 minute ago
task-linking-app-images-new-commit-test          1 minute ago
***

Resources:
No pipelineresources found.

```

### Push a new commit

Once all above steps have been performed, it is time to trigger a new push event in order to test that EvenListener will trigger a new procedure in order to test and deploy this new app version.

If OpenShift cluster is accessible from Internet, it is possible to generate a push/commit event through git command and test the result. In order to add a new repository webhook, please visit the following link [Creating Webhooks](https://developer.github.com/webhooks/creating/).

#### Emulate a new commit

In this case, a new push/commit event is emulated using a curl tool in order to avoid Internet access to our cluster. Please, execute the following commands:

```
$ curl -X POST -k \
-H "Content-Type: application/json" \
-d '{"head_commit":{"id":"bf4bc35c0c77034d7e1493cbf2d9d1b24ab99ddf"},"repository":{"name":"linking-app-chat","url":"https://github.com/acidonper/linking-app-chat.git"}}' https://el-linking-app-chat-nctad-linking-app-cicd.apps-crc.testing

$ curl -X POST -k \
-H "Content-Type: application/json" \
-d '{"head_commit":{"id":"1e5d65d7b6bf121c1b7ca898f5abbe8bf6088d6c"},"repository":{"name":"linking-app-images","url":"https://github.com/acidonper/linking-app-images.git"}}' https://el-linking-app-images-nctad-linking-app-cicd.apps-crc.testing

$ curl -X POST -k \
-H "Content-Type: application/json" \
-d '{"head_commit":{"id":"eb19bb603a2c93b1e6154ded5458fc97224df5e5"},"repository":{"name":"linking-app-back","url":"https://github.com/acidonper/linking-app-back.git"}}' https://el-linking-app-back-nctad-linking-app-cicd.apps-crc.testing

$ curl -X POST -k \
-H "Content-Type: application/json" \
-d '{"head_commit":{"id":"3d7d421588d3181c165048f56ffc277b40ca41a4"},"repository":{"name":"linking-app-front","url":"https://github.com/acidonper/linking-app-front.git"}}' https://el-linking-app-front-nctad-linking-app-cicd.apps-crc.testing
```

### Result

As a result, a new build and deployment have been triggered by Tekton for each microservice. In order to review these events status, it is required to follow next steps:

-   Check Linking App Microservices Pods are running properly

```
$ oc get pods -n linking-app
NAME                         READY   STATUS    RESTARTS   AGE
linking-app-back-1-8uth1     1/1     Running   0          19m
linking-app-chat-9-32lsd     1/1     Running   0          41m
linking-app-front-1-5lsk2    1/1     Running   0          9m
linking-app-images-1-a2ff3   1/1     Running   0          27m
mongodb-1-gtkrf              1/1     Running   0          4d9h
```

-   Check ImageStreams microservices revisions

```
$ oc get is -n nodejs-app-example
NAME                 IMAGE REPOSITORY                                                                        TAGS     UPDATED
linking-app-back     default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-back     latest   23 minutes ago
linking-app-chat     default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-chat     latest   43 minutes ago
linking-app-front    default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-front    latest   11 minutes ago
linking-app-images   default-route-openshift-image-registry.apps-crc.testing/linking-app/linking-app-images   latest   32 minutes ago
```

-   Check Front microservice works properly

```
$ oc get route -n linking-app
NAME                      HOST/PORT                                             PATH   SERVICES             PORT                      TERMINATION     WILDCARD
...
linking-app-front         linking-app-front-linking-app.apps-crc.testing                linking-app-front    linking-app-front-http    edge/Redirect   None

$ curl -k https://linking-app-front-linking-app.apps-crc.testing
```

## License

BSD

## Author Information

Asier Cidon
