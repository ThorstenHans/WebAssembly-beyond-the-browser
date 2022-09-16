# A quick look at krustlet

This repo contains fundamental WebAssembly (Wasm) workloads that could be executed on [krustlet](https://krustlet.dev).

## Setup

- obviously, you must have a krustlet running. You can add krustlet to different Kubernetes distributions and managed Kubernetes services.
- an OCI distribution spec compliant Container Registry (e.g. Azure Container Registry) is required. We will use it as distribution channel for our Wasm workloads
- `wasm32-wasi` must be installed as target (`rustup target add wasm32-wasi`)
- Workloads must be compiled against the `wasm32-wasi` using `cargo build --release --target wasm32-wasi`

## Azure Container Registry Authentication

Ensure your instance of ACR allows anonymous image pulling (required if you want to run the WAGI workload on AKS)

```bash
acrName=foo
rgName=foo-bar

az acr update -n $acrName -g $rgName --anonymous-pull-enabled
```

## Verify krustlet taints

Depending on your environment you may find different `taints` being assigned to the krustlet nodes. Verify if your taints are `wasm32-wasi` or `wasm32-wagi`:

```bash

# get all nodes in your cluster

kubectl get nodes

NAME                 STATUS     ROLES                  AGE    VERSION
kind-control-plane   Ready      control-plane,master   103m   v1.21.1
foobar               Ready      <none>                 39m    1.0.0-alpha.1


# get node taints
kubectl describe node foobar

# omitted
Taints: kubernetes.io/arch=wasm32-wasi:NoExecute
        kubernetes.io/arch=wasm32-wasi:NoSchedule
# omitted
```

Note down the `arch`, you must specify it as part of the Pods `tolerations` (see `pod.yml` in both samples -> `podSpec.tolerations`)

## Publishing Wasm modules to Azure Container Registry (ACR)

Assuming having access to an ACR instance called `foobar`, we must push both Wasm modules (`hello-krustlet` and `hello-wasi`) to the ACR instance. To do so, we use [wasm-to-oci](https://github.com/engineerd/wasm-to-oci)

```bash
# authenticate against ACR (either use Azure CLI or use Docker CLI)
az acr login -n foobar

cd 001-wasm
cargo build --release --target wasm32-wasi

wasm-to-oci push ./target/wasm32-wasi/release/hello-wasm.wasm foobar.azurecr.io/hello-wasm:0.0.1
cd ..

cd 002-wasi
cargo build --release --target wasm32-wasi

wasm-to-oci ./target/wasm32-wasi/release/hello-wasi.wasm foobar.azurecr.io/hello-wasi:0.0.1

cd ..

cd 003-wagi
cargo build --release --target wasm32-wasi

wasm-to-oci ./target/wasm32-wasi/release/hello-wasi.wasm foobar.azurecr.io/hello-wagi:0.0.1

```

## Running hello-wasm in KIND

1. Ensure your `kubectl context` points to your KIND cluster
2. Ensure you've attached krustlet to your KIND cluster (see [scripts](./scripts) folder)

You can run `hello-wasm` by applying the Kubernetes manifest located in the kubernetes subfolder:

```bash
kubectl apply -f ./001-wasm/kubernetes/pod.yml
```

### Running hello-wasm locally

You can run `hello-wasm` locally using any (non-browser) WASM runtime. The following sample uses `wasmtime`:

```bash
cd 001-wasm
cargo build --release --target wasm32-wasi
wasmtime run ./target/wasm32-wasi/release/hello-wasm.wasm
```

## Running hello-wasi in KIND

1. Ensure your `kubectl context` points to your KIND cluster
2. Ensure you've attached krustlet to your KIND cluster (see [scripts](./scripts) folder)
3. Update the `volume` in [pod.yml](./002-wasi/kubernetes/pod.yml) and provide a valid folder on your system

You can run `hello-wasi` by applying the Kubernetes manifest located in the kubernetes subfolder:

```bash
kubectl apply -f ./002-wasi/kubernetes/pod.yml
```

### Running hello-wasi locally

You can run `hello-wasi` locally using any (non-browser) WASM runtime. The following sample uses `wasmtime`:

```bash
cd 002-wasi
cargo build --release --target wasm32-wasi
wasmtime run --dir /some/dir --env TARGET=/same/dir ./target/wasm32-wasi/release/hello-wasi.wasm
```

## Running 003-wagi in AKS

1. Ensure your `kubectl context` points to AKS
2. Ensure WASM Node Pool is provisioned (see [scripts](./scripts) folder)
3. Install NGINX ingress which points to WasmWasi Node Ip (see [scripts](./scripts) folder)

```bash
kubectl apply -f ./003-wagi/kubernetes/pod.yml
```
