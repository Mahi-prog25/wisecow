FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      bash \
      netcat-openbsd \
      cowsay \
      fortune-mod \
      fortunes-min; \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/games:${PATH}"

# non-root for good practice (4499 is unprivileged)
RUN useradd -m -s /bin/bash wisecow
USER wisecow

WORKDIR /app
COPY --chmod=755 wisecow.sh .

EXPOSE 4499
ENTRYPOINT ["bash","-lc","./wisecow.sh"]
