FROM python:3.8.6-alpine

RUN apk update && \
    apk add --no-cache bash \
    openssh-client \
    wget \
    supervisor \
    curl \
    bc \
    gcc \
    musl-dev \
    postgresql-libs \
    postgresql-dev \
    linux-headers \
    augeas-dev \
    openssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    ca-certificates \
    dialog \
    git \
    make

RUN apk add --no-cache \
    libjpeg \
    jpeg-dev \
    zlib-dev \
    freetype-dev \
    lcms2-dev \
    openjpeg-dev \
    tiff-dev \
    tk-dev \
    tcl-dev

# Upgrade pip
RUN pip install --upgrade pip

# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push

RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /start.sh

RUN mkdir /app
CMD ["/start.sh"]
