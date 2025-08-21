IMAGE_NAME=quay.io/foreman/${PROJECT}

FOREMAN_XY_TAG=nightly
FOREMAN_XYZ_TAG=nightly #${FOREMAN_XY_TAG}.0

IMAGE_TAGS=${IMAGE_NAME}:${FOREMAN_XY_TAG} ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}

build:
	podman build --file images/${PROJECT}/Containerfile --tag ${IMAGE_NAME}:${FOREMAN_XYZ_TAG}	.
	$(foreach tag,$(IMAGE_TAGS),\
		podman tag ${IMAGE_NAME}:${FOREMAN_XYZ_TAG} $(tag); \
	)

push:
	$(foreach tag,$(IMAGE_TAGS),\
		podman push $(tag);\
	)
