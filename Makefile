IMAGE := jetstackexperimental/redsocks
IMAGE_TAG := canary

build:
	docker build -t $(IMAGE):$(IMAGE_TAG) .

push: build
	docker push $(IMAGE):$(IMAGE_TAG)
