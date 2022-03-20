# rport image
[![Docker](https://github.com/yusufhm/rport-image/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/yusufhm/rport-image/actions/workflows/docker-publish.yml)

Docker/kubernetes image for the excellent rport.io remote systems manager.

## Multi-arch

Currently builds images for

 - linux/amd64
 - linux/arm64

## Configuration via environment variables

Configuration can always be provided by mounting a `/etc/rport/rportd.conf` file, or you can provide the following environment variables which will populate the file from [this template](/rportd.conf.template). See [rportd.example.config](https://github.com/cloudradar-monitoring/rport/blob/master/rportd.example.conf) for all available configuration.

| Variable | Default value | Description |
| --- | --- | --- |
| SERVER_ADDRESS  | "0.0.0.0:8080"                         | IP address and port the HTTP server listens on. |
| SERVER_URL      | "http://0.0.0.0:8080"                  | Full client connect URL. |
| SERVER_KEY_SEED | "5448e69530b4b97fb510f96ff1550500b093" | Option string to seed the generation of a ECDSA public and private key pair. Highly recommended. Not using it is a big security risk. Use "openssl rand -hex 18" to generate a secure key seed. |
| SERVER_AUTH     | "clientAuth1:1234"                     | Optional string representing a single client auth credentials, in the form of <client-auth-id>:<password>. |
| SERVER_DATA_DIR | "/var/lib/rport"                       | Optional param to define a local directory path to store internal data. |
| API_ADDRESS     | "0.0.0.0:3000"                         | IP address and port the API server/frontend UI listens on. |
| API_AUTH        | "admin:foobaz"                         | Defines <user>:<password> authentication pair for accessing the API. Enables access for a single user. |
| API_DOC_ROOT    | "/var/www/html"                        | Place where the frontend files (html/js) go. |
