# Repository agent notes

This repository builds the Foreman server and Foreman Proxy OCI images.

## RPM build modes

- `master` builds the nightly images with ordinary DNF repository resolution; this is
  not a hermetic RPM build.
- `foreman-5.0` uses Hermeto-prefetched RPMs in Konflux. The `.tekton/foreman-5-0-*`
  and `.tekton/foreman-proxy-5-0-*` pipelines set `hermetic: "true"` and pass
  `USE_HERMETO_REPOS=true`.
- Foreman and Foreman Proxy have separate `rpms.in.yaml` and `rpms.lock.yaml` files in
  their image directories. Their `contentOrigin.repofiles` entries refer to `.repo`
  files in the root `repos/` directory.
- `make build` invokes Podman directly and does not run Hermeto. Do not treat a local
  build as validation of Konflux prefetching.

## Refreshing RPM locks

The shared Makefile targets are present on `master` for future versioned branches, but
current `master` has no RPM lock inputs. On `foreman-5.0`, use
`make refresh-rpm-lockfiles` to regenerate both locks, or use
`make refresh-foreman-rpm-lockfile` and `make refresh-foreman-proxy-rpm-lockfile` to
refresh one image at a time. The helper image is built locally with Podman, defaults to
upstream release `v0.30.1`, and is not published. The target mounts the repository with
`:z` for SELinux relabeling; keep it independent of `build` and GHA workflows.

Each input has an explicit `packages` list. The lockfile tool uses that list instead of
scanning the Containerfile, so RPM package changes must be reflected in the matching
`rpms.in.yaml`. Refresh and review the corresponding `rpms.lock.yaml` after package or
repository changes.

## Publishing and troubleshooting

Konflux publishes images through the branch push pipelines after merge. Do not present
local Makefile `push` targets as the release workflow. For hermetic failures, inspect
the relevant Foreman or Foreman Proxy `prefetch-dependencies` task logs first, then the
`build-container` task; verify the `.tekton` file for that image and branch.

## References

- [shared hermetic RPM guide](https://github.com/theforeman/theforeman-rel-eng-konflux/blob/develop/docs/hermetic-rpm-builds.md)
- [Konflux dependency prefetching](https://konflux-ci.dev/docs/building/prefetching-dependencies/)
- [Hermeto RPM dependencies](https://hermetoproject.github.io/hermeto/rpm/)
- [rpm-lockfile-prototype container instructions](https://github.com/konflux-ci/rpm-lockfile-prototype#running-in-a-container)
- [rpm-lockfile-prototype package precedence](https://github.com/konflux-ci/rpm-lockfile-prototype#containerfile-package-scanning-and-packages-precedence)
- [MintMaker RPM lockfiles](https://konflux-ci.dev/docs/mintmaker/rpm-lockfile/)
- [MintMaker support](https://konflux-ci.dev/docs/mintmaker/support/)
- [MintMaker user guide](https://konflux-ci.dev/docs/mintmaker/user/)
- [Renovate documentation](https://docs.renovatebot.com/)
- [Foreman OCI images README](https://github.com/theforeman/foreman-oci-images/blob/master/README.md)
- [Pulp OCI images README](https://github.com/theforeman/pulp-oci-images/blob/master/README.md)
- [Candlepin OCI images README](https://github.com/theforeman/candlepin-oci-images/blob/master/README.md)
