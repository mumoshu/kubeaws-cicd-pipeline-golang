Usage:

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
