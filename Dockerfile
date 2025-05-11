FROM debian:12

ARG DEBIAN_FRONTEND=noninteractive

# renovate: deb=winehq-stable registry=https://dl.winehq.org/wine-builds/debian?components=main&binaryArch=i386&suite=bookworm
ARG WINE_VERSION=10.0.0.0~bookworm-1
ARG DOTNET_VERSION=9.0.203
# Version 5.0.2 is the latest version of WiX Toolset that does not require Open Source Maintenance Fee.
# https://github.com/wixtoolset/wix/blob/ffbfeb3c0b9cb8084bd366404c0cb06d42e8caaf/OSMFEULA.txt
ARG WIXTOOLSET_VERSION=5.0.2

ENV WINEPATH="C:\\users\\wix\\.dotnet\\tools" \
    WINEPREFIX="/home/wix/.wine" \
    XDG_RUNTIME_DIR="/tmp/" \
    WINEARCH=win32 \
    WINEDEBUG=-all \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false

RUN set -ex \
    && set -o allexport && . /etc/os-release && set +o allexport \
    && dpkg --add-architecture i386 \
    && apt-get update -qq  \
    && apt-get install --no-install-recommends ca-certificates curl xauth xvfb xz-utils p7zip unzip -qqy \
    && curl -sSfLo /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && curl -sSfLo /etc/apt/sources.list.d/winehq.sources https://dl.winehq.org/wine-builds/debian/dists/$VERSION_CODENAME/winehq-$VERSION_CODENAME.sources \
    && apt-get update -qq && apt-get install --no-install-recommends winehq-stable=${WINE_VERSION} -qqy \
    && useradd -m wix \
    && apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && curl https://raw.githubusercontent.com/Winetricks/winetricks/refs/heads/master/src/winetricks -o /usr/local/bin/winetricks \
    && chmod +x /usr/local/bin/winetricks \
    # https://github.com/dotnet/runtime/issues/98441
    && printf '#!/bin/sh\nexec script --return --quiet -c "wine dotnet $*" /dev/null' > /usr/local/bin/dotnet  \
    && printf '#!/bin/sh\nexec wine wix.exe $@' > /usr/local/bin/wix.exe  \
    && chmod +x /usr/local/bin/dotnet /usr/local/bin/wix.exe \
    && ln -sf /usr/local/bin/wix.exe /usr/local/bin/wix

USER wix

RUN set -ex \
    && curl -sSfLo /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe https://builds.dotnet.microsoft.com/dotnet/Sdk/${DOTNET_VERSION}/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe

RUN curl -sSfLo /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.zip https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_VERSION}/dotnet-sdk-${DOTNET_VERSION}-win-x86.zip \
    && wineboot --init \
    && mkdir ~/.wine/drive_c/SDK/ \
    && unzip -d ~/.wine/drive_c/SDK/ /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.zip
