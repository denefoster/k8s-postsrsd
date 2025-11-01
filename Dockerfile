FROM debian:trixie AS builder

ENV POSTSRSD_VER=2.0.11

WORKDIR /app

RUN apt-get update && apt-get install -fy --no-install-recommends \
    automake autoconf curl cmake clang libhiredis-dev libconfuse-dev \
    libmilter-dev libsqlite3-dev git make ca-certificates flex

RUN curl -L -O \
    https://github.com/roehling/postsrsd/archive/refs/tags/${POSTSRSD_VER}.tar.gz

RUN tar zxvfp ${POSTSRSD_VER}.tar.gz

RUN cd postsrsd-${POSTSRSD_VER} && mkdir _build && cd _build \
       && cmake .. -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DWITH_SQLITE=ON \
       -DWITH_REDIS=ON \
       -DWITH_MILTER=ON \
       -DBUILD_TESTING=OFF \
       && make -j

FROM debian:trixie AS runtime

ENV POSTSRSD_VER=2.0.11

RUN useradd postsrsd -d /var/lib/postsrsdr

COPY --from=builder /app/postsrsd-${POSTSRSD_VER}/_build/postsrsd /app/postsrsd

COPY docker-entrypoint.sh /app/docker-entrypoint.sh

EXPOSE 9997

EXPOSE 10003

CMD ["/app/docker-entrypoint.sh"]
