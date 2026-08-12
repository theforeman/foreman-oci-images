PROJECT=foreman
IMAGE_NAME=quay.io/foreman/${PROJECT}

KATELLO_VERSION=5.0

FOREMAN_XY_TAG=5.0
FOREMAN_XYZ_TAG=5.0.0-rc1

IMAGE_TAGS=${IMAGE_NAME}:${FOREMAN_XY_TAG} ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}

build:
	podman build --file images/${PROJECT}/Containerfile --build-arg FOREMAN_VERSION=${FOREMAN_XY_TAG} --build-arg KATELLO_VERSION=${KATELLO_VERSION} --tag ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}	.
	$(foreach tag,$(IMAGE_TAGS),\
		podman tag ${IMAGE_NAME}:${FOREMAN_XYZ_TAG} $(tag); \
	)

push:
	$(foreach tag,$(IMAGE_TAGS),\
		podman push $(tag);\
	)
