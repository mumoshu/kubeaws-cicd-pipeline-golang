.PHONY: test
test:
	sh -c 'ENV=test IMAGE=mumoshu/golang-k8s-aws:1.9.1 COMMAND="helmfile sync" SERVICE_ACCOUNT=default PROJECT=deis/empty-testbed helmfile sync'

.PHONY: binary
binary:
	scripts/build

.PHONY: image
image:
	scripts/dockerbuild
