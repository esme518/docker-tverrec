#
# Dockerfile for tverrec
#

FROM alpine as source

ARG URL=https://api.github.com/repos/dongaba/TVerRec/releases/latest

WORKDIR /app

RUN set -ex \
    && apk add --update --no-cache curl \
    && wget -O TVerRec.tar.gz $(curl -s $URL | grep tarball_url | egrep -o '\"http.+\"' | sed 's/"//g') \
    && mkdir TVerRec \
    && tar xvf TVerRec.tar.gz -C TVerRec --strip-components 1 \
    && cd TVerRec \
    && rm -rf .git* .vscode \
    && chmod a+x ./unix/*.sh

FROM mcr.microsoft.com/powershell:ubuntu-22.04
COPY --from=source /app/TVerRec /app/TVerRec

ENV POWERSHELL_TELEMETRY_OPTOUT=1

WORKDIR /app/TVerRec

RUN set -ex \
    && apt-get update && apt-get install -y \
       busybox \
       curl \
       python3 \
       xz-utils \
    && ln -s /usr/bin/busybox /usr/bin/vi \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/*

RUN set -ex \
    && mkdir -p -m 777 \
       /mnt/Temp \
       /mnt/Work \
       /mnt/Save

RUN set -ex \
    && echo '$script:downloadBaseDir = '\''/mnt/Work'\''' >> ./conf/user_setting.ps1 \
    && echo '$script:downloadWorkDir = '\''/mnt/Temp'\''' >> ./conf/user_setting.ps1 \
    && echo '$script:saveBaseDir = '\''/mnt/Save'\''' >> ./conf/user_setting.ps1

WORKDIR /app/TVerRec/unix

ENTRYPOINT ["/bin/bash"]
CMD ["start_tverrec.sh"]
