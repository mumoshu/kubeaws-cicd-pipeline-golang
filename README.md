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

### Install `sops-vault` app

[sops-vault](https://github.com/mumoshu/sops-vault) allows you to transparently decrypt a required credential for running commands.

### Install `helmfile` sync

[helmfile](https://github.com/roboll/helmfile) allows you to declaratively manage all the helm releases forming your app deployed to K8S.

### Compose `helmfile.yaml`



### Deploy your app along with a deployment pipeline

```
$ ENV=test IMAGE=your-docker-image TAG=your-docker-image-tag sops-vault run helmfile sync
```

- `sops-vault` decrypts `kubeconfig` using AWS KMS and then calls out to `helmfile sync`
- `helmfile sync` deploys all the helm releases as declared in `helmfile.yaml`

### Manually triggering a deployment pipeline

Trigger a deployment (again) by running `deploy` app to call GitHub Deployment API for creating a new deployment:

```
$ export GITHUB_TOKEN=<the token generated in above>

$ deploy --env test <your github org>/<your github repo> e.g. `deploy --env test mumoshu/myrepo`
```

## Usage:

```
# Preparation

$ git add brigade.js helmfile.yaml values.yaml environments/
$ git commit -m 'Enable helmfile+brigade based deployment pipeline'
$ git push origin master

# Invoke this via:

# * Your shell
ENV=test IMAGE=mumoshu/golang-k8s-aws:1.9.1 COMMAND="helmfile sync" SERVICE_ACCOUNT=default PROJECT=deis/empty-testbed helmfile sync

# It will update:
# (1) All the charts included in helmfile, including brigade project and your app(s)

# And then trigger a deployment via:
# * GitHub Webhook events(Pull request, Deployment)
#
# So that it will update:
# (1) All the charts included in helmfile, including brigade project and your app(s)
```
