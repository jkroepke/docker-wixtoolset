FROM debian:12

ARG DEBIAN_FRONTEND=noninteractive

# renovate: deb=winehq-staging registry=https://dl.winehq.org/wine-builds/debian?components=main&binaryArch=i386&suite=bookworm
ARG WINE_VERSION=10.0.0~bookworm-1
ARG WINE_MONO_VERSION=10.0.0
ARG DOTNET_VERSION=9.0.203
ARG WIXTOOLSET_VERSION=5.0.2

ENV WINEPATH="C:\\users\\wix\\.dotnet\\tools" \
    WINEPREFIX="/home/wix/.wine" \
    WINEARCH=win32 \
    WINEDEBUG=-all \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false

RUN set -ex \
    && dpkg --add-architecture i386  \
    && apt-get update -qq  \
    && apt-get install --no-install-recommends ca-certificates curl xauth xvfb xz-utils -qqy \
    && curl -sSfLo /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && curl -sSfLo /etc/apt/sources.list.d/winehq-bookworm.sources https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt-get update -qq && apt-get install --no-install-recommends winehq-staging=${WINE_VERSION} -qqy \
    && useradd -m wix \
    && apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && mkdir -p /opt/wine/mono/ && chown -R wix:wix /opt/wine/mono/ \
    \
    # https://github.com/dotnet/runtime/issues/98441
    && printf '#!/bin/sh\nexec script --return --quiet -c "wine dotnet $*" /dev/null' > /usr/local/bin/dotnet  \
    && printf '#!/bin/sh\nexec wine wix.exe $@' > /usr/local/bin/wix.exe  \
    && chmod +x /usr/local/bin/dotnet /usr/local/bin/wix.exe \
    && ln -sf /usr/local/bin/wix.exe /usr/local/bin/wix

USER wix


RUN set -ex \
    && curl -sSfLo /tmp/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz https://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz  \
    && tar -xf /tmp/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz -C /opt/wine/mono/ \
    && rm -f /tmp/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz \
    && curl -sSfLo /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe https://builds.dotnet.microsoft.com/dotnet/Sdk/${DOTNET_VERSION}/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe  \
    && xvfb-run sh -c "wineboot --init && wine /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe /q /norestart" \
    && rm -f /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe \
    && dotnet tool install --global wix --version ${WIXTOOLSET_VERSION} \
    && wine wix.exe --version \
    && wix extension add -g WixToolset.Util.wixext/${WIXTOOLSET_VERSION} \
    && wix extension add -g WixToolset.Firewall.wixext/${WIXTOOLSET_VERSION} \
    && wix extension add -g WixToolset.UI.wixext/${WIXTOOLSET_VERSION}
