# rport image
[![Docker](https://github.com/yusufhm/rport-image/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/yusufhm/rport-image/actions/workflows/docker-publish.yml)

Docker/kubernetes image for the excellent rport.io remote systems manager.

## Multi-arch

Currently builds images for

 - linux/amd64
 - linux/arm64

## Configuration via environment variables

Configuration can always be provided by mounting a `/etc/rport/rportd.conf` file, or you can provide the following environment variables which will populate the file from [this template](/rportd.conf.template). See [rportd.example.conf](https://github.com/cloudradar-monitoring/rport/blob/master/rportd.example.conf) for all available configuration.

| Variable | Default value | Description |
| --- | --- | --- |
| SERVER_ADDRESS  | "0.0.0.0:8080"                         | IP address and port the HTTP server listens on. |
| SERVER_URL      | "http://0.0.0.0:8080"                  | Full client connect URL. |
| SERVER_KEY_SEED | "5448e69530b4b97fb510f96ff1550500b093" | Option string to seed the generation of a ECDSA public and private key pair. Highly recommended. Not using it is a big security risk. Use "openssl rand -hex 18" to generate a secure key seed. |
| SERVER_AUTH     | "clientAuth1:1234"                     | Optional string representing a single client auth credentials, in the form of `<client-auth-id>:<password>`. |
| SERVER_DATA_DIR | "/var/lib/rport"                       | Optional param to define a local directory path to store internal data. |
| API_ADDRESS     | "0.0.0.0:3000"                         | IP address and port the API server/frontend UI listens on. |
| API_AUTH        | "admin:foobaz"                         | Defines `<user>:<password>` authentication pair for accessing the API. Enables access for a single user. |
| API_DOC_ROOT    | "/var/www/html"                        | Place where the frontend files (html/js) go. |

## Running on Kubernetes

The following sample manifest will run the image using config from a configmap.

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rport-config
  namespace: default
  labels:
    app.kubernetes.io/name: rport
    app.kubernetes.io/instance: rport
data:
  rportd.conf: |
    [server]
      address = "0.0.0.0:8080"
      url = ["http://0.0.0.0:8080", "https://rport.example.com/ws"]
      key_seed = "5448e69530b4b97fb510f96ff1550500b093"
      auth = "clientAuth1:1234"
      data_dir = "/var/lib/rport"

    [api]
      address = "0.0.0.0:3000"
      auth = "admin:foobaz"
      doc_root = "/var/www/html"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rport
  namespace: default
spec:
  selector:
    matchLabels:
      app: rport
  replicas: 1
  template:
    metadata:
      labels:
        app: rport
    spec:
      nodeSelector:
        role: server
      containers:
        - name: rport
          image: ghcr.io/yusufhm/rport:v0.1.0
          ports:
            - containerPort: 8080
            - containerPort: 3000
          volumeMounts:
            - name: config
              mountPath: /etc/rport/rportd.conf
              subPath: rportd.conf
              readOnly: true
      volumes:
        - name: config
          projected:
            defaultMode: 0444
            sources:
            - configMap:
                name: rport-config
                items:
                - key: rportd.conf
                  path: rportd.conf

---
apiVersion: v1
kind: Service
metadata:
  name: rport
  namespace: default
spec:
  selector:
    app: rport
  ports:
    - name: server
      protocol: TCP
      port: 8080
      targetPort: 8080
    - name: api
      protocol: TCP
      port: 3000
      targetPort: 3000

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rport
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - secretName: rport-tls-secret
      hosts:
        - rport.example.com
  rules:
    - host: rport.example.com
      http:
        paths:
          - path: /ws
            pathType: Prefix
            backend:
              service:
                name: rport
                port:
                  number: 8080
          - path: /
            pathType: Prefix
            backend:
              service:
                name: rport
                port:
                  number: 3000

```
