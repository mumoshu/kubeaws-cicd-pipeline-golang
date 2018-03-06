## Installation

### Generate GitHHub token

Generate a new GitHub personal access token for calling GitHub Deployments API:

https://github.com/settings/tokens

- Click "Generate new token"
- Input whatever you think helpful to "Token description"
- In "Select scopes", check "repo_deployment"
- Click "Generate token"
- Save the generated token in a safe place

### Setup the `deploy` app

Install [remind101/deploy](https://github.com/remind101/deploy).

Run the following steps to verify it is working:

```
$ export GITHUB_TOKEN=<the token generated in above>

$ deploy --env test <your github org>/<your github repo> e.g. `deploy --env test mumoshu/myrepo`
```

See it fail like this(This is expected as we don't have a deployment pipeline to react the deployment yet!):

```
Deploying the following commits:

<your commit author full name>        	<your commit message>

See entire diff here: https://github.com/mumoshu/myrepo/compare/ad48eef89f393cde869b6190c7fc406e19bbd8ce...master

Deploying mumoshu/myrepo to test...
Error from github deployments: Timed out waiting for build to start. Did you add a webhook to handle deployment events?
```

### Setup AWS credentials and AWS KMS access

Using a SSO service like OneLogin:

```
$ onelogin-aws-login

$ export AWS_PROFILE=<your profile name obtained from >
```

Or explicitly setting a pair of access key id and secret access key(Not recommended):

```
$ export AWS_ACCESS_KEY_ID=...
$ export AWS_SECRET_ACCESS_KEY=...
```

### Install helm

[helm](https://github.com/kubernetes/helm/releases) is a package manager likt `apt` or `yum` for Kubernetes.

### Install `sops-vault` app

[sops-vault](https://github.com/mumoshu/sops-vault) allows you to transparently decrypt a required credential for running commands.

### Install `helmfile` sync

[helmfile](https://github.com/roboll/helmfile) allows you to declaratively manage all the helm releases forming your app deployed to K8S.

### Compose `helmfile.yaml`

Customize the [`helmfile` contained in this repository](https://github.com/mumoshu/kubeaws-cicd-pipeline-golang/blob/master/helmfile.yaml) according to your use-case.

In the default helmfile.yaml, we have:

- [kubeaws-charts/std](https://github.com/mumoshu/kubeaws-charts/tree/master/std) chart to easily deploy your stateless web/grpc app to K8S without writing too much boiler-plate helm templates
- [Azure/brigade](https://github.com/Azure/brigade) project to run `helmfile sync` whenever a deployment is triggered
- WIP: A webhook gateway to trigger the brigade project whenever a github deployment is made, without exposing the K8S API server to the Internet

### Deploy your app along with a deployment pipeline

```
$ git clone https://github.com/mumoshu/kubeaws-cicd-pipeline-golang temp/
$ cp temp/{brigade.js,helmfile.yaml,ship/} .
$ rm -rf temp
$ git add brigade.js helmfile.yaml values.yaml ship/
$ git commit -m 'Enable an automated deployment pipeline'
$ git push origin master
```

```
$ export ENV=test

$ export BRIGADE_IMAGE=mumoshu/golang-k8s-aws:1.9.1
$ export BRIGADE_COMMAND="helmfile sync"
$ export BRIGADE_SERVICE_ACCOUNT=default

$ export PROJECT=<your github org>/<your repo>

$ export APP_IMAGE=<your app's docker image>:<commit id>

$ sops-vault run helmfile sync
```

- `sops-vault` decrypts `kubeconfig` using AWS KMS and then calls out to `helmfile sync`
- `helmfile sync` deploys all the helm releases as declared in `helmfile.yaml`

### Manually triggering a deployment pipeline

Trigger a deployment (again) by running `deploy` app to call GitHub Deployment API for creating a new deployment:

```
$ export GITHUB_TOKEN=<the token generated in above>

$ deploy --env test <your github org>/<your github repo> e.g. `deploy --env test mumoshu/myrepo`
```

### Automatically triggering a deployment pipeline

Add the same `deploy` command and envvars to your CI pipeline definition in e.g. .circleci/config.yml when you're a CircleCI user.

## OPTIONAL: Customizations

### Notifying deployments to Slack

Update the following section of your `helmfile.yaml`:

```
  - name: secrets.slackWebhook
    value: ""
  - name: secrets.slackUsername
    value: ""
```

To:

```
  - name: secrets.slackWebhook
    value: "{{ env \"SLACK_WEBHOOK\" }}"
  - name: secrets.slackUsername
    value: "{{ env \"SLACK_USERNAME\" }}"
```
