.PHONY: test
test:
	sh -c 'ENV=test IMAGE=mumoshu/golang-k8s-aws:1.9.1 COMMAND="helmfile sync" SERVICE_ACCOUNT=default PROJECT=deis/empty-testbed helmfile sync'

.PHONY: binary
binary:
	ship/build/scripts/build

.PHONY: image
image:
	ship/build/scripts/dockerbuild

.PHONY: trigger-deploy
trigger-deploy:
	ship/release/scripts/trigger-deploy

.PHONY: deploy
deploy:
	ship/release/scripts/deploy

.PHONY: dockerpush
dockerpush:
	UPLOAD_ONLY=1 ship/build/scripts/dockerbuild
