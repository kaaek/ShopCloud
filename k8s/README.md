# ShopCloud Kubernetes Manifests

This folder is used by `.github/workflows/shopcloud-ci-cd.yml`.

The manifest intentionally has no hard-coded namespace. The workflow chooses the namespace at deploy time:

- `dev` branch -> `shopcloud-dev` by default
- `main` branch -> `shopcloud-prod` by default, with GitHub Environment approval

You can override those names with GitHub repository variables:

- `K8S_NAMESPACE_DEV`
- `K8S_NAMESPACE_PROD`

The workflow creates the Kubernetes secret `shopcloud-app-secrets` during deployment from GitHub Secrets. The Java and React source code is not changed.

Frontend nginx config is mounted from a Kubernetes ConfigMap because the existing frontend Dockerfiles do not copy the nginx reverse-proxy config into the image.
