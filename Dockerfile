FROM gliderlabs/alpine:3.2

# ENV VERSION=v0.10.40 CMD=node DOMAIN=nodejs.org CFLAGS="-D__USE_MISC"
ENV VERSION=v4.0.0-rc.4 CMD=node DOMAIN=nodejs.org RELEASE_TYPE=rc
# ENV VERSION=v2.3.4 CMD=iojs DOMAIN=iojs.org NO_NPM_UPDATE=true

# For base builds
# ENV CONFIG_FLAGS="--without-npm" RM_DIRS=/usr/include
# ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libgcc libstdc++" RM_DIRS=/usr/include

RUN apk-install curl make gcc g++ python linux-headers paxctl libgcc libstdc++
RUN curl -sSL https://${DOMAIN}/download/${RELEASE_TYPE}/${VERSION}/${CMD}-${VERSION}.tar.gz | tar -xz
WORKDIR /${CMD}-${VERSION} 
RUN ./configure --prefix=/usr ${CONFIG_FLAGS}
RUN make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  make install && \
  paxctl -cm /usr/bin/${CMD} && \
  cd / && \
  if [ -x /usr/bin/npm -a -z "$NO_NPM_UPDATE" ]; then \
    npm install -g npm && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del curl make gcc g++ python linux-headers paxctl ${DEL_PKGS} && \
  rm -rf /etc/ssl /${CMD}-${VERSION} ${RM_DIRS} \
    /usr/share/man /tmp/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html

