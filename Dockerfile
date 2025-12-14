FROM alpine:3 as downloader

ARG RPORT_VERSION=0.9.13
ARG FRONTEND_BUILD=1.0.1-1-build-1151
ARG NOVNC_VERSION=1.4.0
ARG ENVPLATE_VERSION=1.0.3

RUN apk add unzip

WORKDIR /app/

RUN set -ex \
    && arch=$(uname -m) \
    && if [ "${arch}" == "aarch64" ]; then release_arch="arm64"; else release_arch=${arch}; fi \
    && wget https://github.com/openrport/openrport/releases/download/${RPORT_VERSION}/rportd_${RPORT_VERSION}_linux_${release_arch}.tar.gz -O rportd.tar.gz \
    && tar xzf rportd.tar.gz rportd

RUN set -e \
    && wget https://downloads.rport.io/frontend/stable/rport-frontend-stable-${FRONTEND_BUILD}.zip -O frontend.zip \
    && unzip frontend.zip -d ./frontend

RUN set -e \
    && wget https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.zip -O novnc.zip \
    && unzip novnc.zip && mv noVNC-${NOVNC_VERSION} ./novnc

WORKDIR /envplate
RUN set -e \
    && arch=$(uname -m) \
    && if [ "${arch}" == "aarch64" ]; then release_arch="arm64"; else release_arch=${arch}; fi \
    && release_name=envplate_${ENVPLATE_VERSION}_$(uname -s)_${release_arch}.tar.gz \
    && wget https://github.com/kreuzwerker/envplate/releases/download/v${ENVPLATE_VERSION}/${release_name} -O envplate.tar.gz \
    && tar -xf envplate.tar.gz

FROM debian:11

COPY --from=downloader /app/rportd /usr/local/bin/rportd
COPY --from=downloader /app/frontend/ /var/www/html/
COPY --from=downloader /app/novnc/ /var/lib/rport-novnc
COPY --from=downloader /envplate/envplate /usr/local/bin/ep

COPY entrypoint.sh /entrypoint.sh

RUN set -e \
    && useradd -d /var/lib/rport -m -U -r -s /bin/false rport \
    && mkdir -p /etc/rport && chown rport:rport /etc/rport

USER rport

COPY --chown=rport:rport rportd.conf.template /etc/rportd.conf.template

VOLUME [ "/var/lib/rport/" ]

EXPOSE 8080
EXPOSE 3000

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh", "/usr/local/bin/rportd", "--data-dir", "/var/lib/rport", "--config", "/etc/rport/rportd.conf" ]
