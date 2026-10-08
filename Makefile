PROJECT=foreman
IMAGE_NAME=quay.io/foreman/${PROJECT}

KATELLO_VERSION=nightly

FOREMAN_XY_TAG=nightly
FOREMAN_XYZ_TAG=nightly #${FOREMAN_XY_TAG}.0

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

# RPM lockfile maintenance. Keep this target on master for future version branches.
RPM_LOCKFILE_INPUTS := images/foreman/rpms.in.yaml images/foreman-proxy/rpms.in.yaml
RPM_LOCKFILE_VERSION ?= v0.30.1
RPM_LOCKFILE_IMAGE ?= localhost/rpm-lockfile-prototype:$(RPM_LOCKFILE_VERSION)
RPM_LOCKFILE_CONTAINERFILE_URL ?= https://raw.githubusercontent.com/konflux-ci/rpm-lockfile-prototype/refs/heads/main/Containerfile

.PHONY: check-rpm-lockfile-inputs refresh-rpm-lockfiles refresh-rpm-lockfile refresh-foreman-rpm-lockfile refresh-foreman-proxy-rpm-lockfile rpm-lockfile-prototype-image
check-rpm-lockfile-inputs:
	@for input in $(RPM_LOCKFILE_INPUTS); do \
		if [ ! -f "$$input" ]; then \
			echo "Missing $$input; run this target from a branch with hermetic RPM inputs." >&2; \
			exit 1; \
		fi; \
	done

refresh-rpm-lockfiles: refresh-rpm-lockfile

refresh-rpm-lockfile: refresh-foreman-rpm-lockfile refresh-foreman-proxy-rpm-lockfile

refresh-foreman-rpm-lockfile: rpm-lockfile-prototype-image
	podman run --rm --volume "$(CURDIR):/work:z" \
		--workdir /work/images/foreman \
		$(RPM_LOCKFILE_IMAGE) --outfile=rpms.lock.yaml rpms.in.yaml

refresh-foreman-proxy-rpm-lockfile: rpm-lockfile-prototype-image
	podman run --rm --volume "$(CURDIR):/work:z" \
		--workdir /work/images/foreman-proxy \
		$(RPM_LOCKFILE_IMAGE) --outfile=rpms.lock.yaml rpms.in.yaml

rpm-lockfile-prototype-image: check-rpm-lockfile-inputs
	@if ! podman image exists "$(RPM_LOCKFILE_IMAGE)"; then \
		curl --fail --location "$(RPM_LOCKFILE_CONTAINERFILE_URL)" | \
			podman build --build-arg GIT_REF=tags/$(RPM_LOCKFILE_VERSION) \
				--tag "$(RPM_LOCKFILE_IMAGE)" -; \
	fi
