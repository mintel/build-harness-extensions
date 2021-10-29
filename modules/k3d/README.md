# k3d 

https://k3d.io

## Usage

This example shows spinning up a K3d cluster, deploying a local image, and accessing the endpoint.

Spin up the cluster:

```
make k3d/create
```

Validate that the nodes are up, and all pods are running:

```
kubectl get nodes
kubectl get pods --all-namespaces
```

Create a local image, using [Nginx](https://www.nginx.com/) as an example:

```
# Tag it and push it to the docker-registry which this module creates for us

docker tag nginx:latest k3d-default.localhost:5000/mynginx:v0.1           
docker push k3d-default.localhost:5000/mynginx:v0.1               
```

Deploy our custom-tagged Nginx image:
```
kubectl create deployment nginx --image=k3d-default.localhost:5000/mynginx:v0.1
kubectl create service clusterip nginx --tcp=80:80
```

Expose it via an Ingress:
```
cat <<EOF | kubectl apply -f -
# apiVersion: networking.k8s.io/v1beta1 # for k3s < v1.19
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /my-nginx
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
```

You can now access your custom built nginx at http://localhost:8080/my-nginx

To cleanup, you can shutdown your local cluster:

```
make k3d/delete
```

## Traefik

We bundle [Treafik](https://traefik.io/) as part of this module.

You can access the Traefik dashboard (sometimes useful for debugging services) like so:

```
# Port-forward to local-port 9000

kubectl port-forward -n traefik $(kubectl get pods -n traefik -l app.kubernetes.io/instance=traefik -o name) 9000
```

Now visit: http://localhost:9000/dashboard/

## Notes

- Access sites which have an Ingress via port `8080` on localhost (this maps to port `80` inside the cluster)
- Tag images against the local docker-registry using `k3d-default.localhost:5000`
- Deleting a cluster via `make k3d/delete` does not (by default) remove the local docker-registry
- The Kubernetes version defaults (using `K3D_K8S_IMAGE`) to the latest verison of Kubernetes we support.
- If you have a `mintelnet` docker-network pre-created (to avoid overlapping IP issues on the VPN), the module will make use of it (by default).