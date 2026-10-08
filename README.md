# Foreman Container Images

The [foreman-oci-images](https://github.com/theforeman/foreman-oci-images) repository is used to provide a Foreman container image configured for the Foreman project's use case.
It follows [foremanctl's container builds structure](https://github.com/theforeman/foremanctl/blob/master/docs/developer/container-image-builds.md).

Note that OCI stands for "Open Container Initiative", see [here](https://opencontainers.org/).

## RPM build modes by branch

| Branch | RPM build mode |
| --- | --- |
| `master` (nightly) | Non-hermetic; DNF resolves RPMs during the build. |
| `foreman-5.0` | Hermetic in Konflux; `USE_HERMETO_REPOS=true` enables [Hermeto prefetching](https://konflux-ci.dev/docs/building/prefetching-dependencies/). |

On `foreman-5.0`, Foreman and Foreman Proxy have separate inputs and locks: `images/foreman/rpms.in.yaml`
and `images/foreman/rpms.lock.yaml`, plus the corresponding files under
`images/foreman-proxy/`. Both use the repository files under `repos/`.

`make build` runs Podman directly and does not run Hermeto. It is useful for a local
image build, but does not validate Konflux's hermetic prefetch step.

### Refresh the RPM lockfiles

The refresh target is available on `foreman-5.0`. The same Makefile
target is also present on `master` for future stable branches; current
`master` has no lock inputs, so run it only on a branch containing the
hermetic RPM inputs:

```bash
git switch foreman-5.0
make refresh-rpm-lockfiles
git diff -- images/foreman/rpms.lock.yaml images/foreman-proxy/rpms.lock.yaml
```

The target builds the official [rpm-lockfile-prototype container workflow](https://github.com/konflux-ci/rpm-lockfile-prototype#running-in-a-container) locally with Podman when needed, then regenerates both locks from their input files and referenced `.repo` files. The helper image is not published, and `make build` is unaffected. The tool defaults to `v0.30.1`; set `RPM_LOCKFILE_VERSION` to intentionally test or adopt another upstream release.

Both input files define explicit `packages` lists, which take precedence over [Containerfile package scanning](https://github.com/konflux-ci/rpm-lockfile-prototype#containerfile-package-scanning-and-packages-precedence). Update the matching input file when changing an image's RPM package set, then refresh and review its lockfile.

See the [shared hermetic RPM guide](https://github.com/theforeman/theforeman-rel-eng-konflux/blob/develop/docs/hermetic-rpm-builds.md) for the shared branch matrix and troubleshooting guidance.

Related OCI image repositories:

- [Foreman OCI images](https://github.com/theforeman/foreman-oci-images/blob/master/README.md)
- [Pulp OCI images](https://github.com/theforeman/pulp-oci-images/blob/master/README.md)
- [Candlepin OCI images](https://github.com/theforeman/candlepin-oci-images/blob/master/README.md)

## How to Build

To build the container images locally:

```
make build
```

## Publishing

After a change is merged, Konflux builds and publishes the image through the branch's
push pipeline. Check that Konflux pipeline to confirm publication; `make push` is not
the release workflow for these images.

## Usage

These container images are expected to be used additional tooling that manages orchestrating relevant actions like database migration.
The primary tool targeting the use of these images is [foremanctl](https://github.com/theforeman/foremanctl).
