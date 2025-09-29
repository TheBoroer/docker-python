ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}-slim

# Make APT robust across current and future EOL Debian suites
ARG DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    . /etc/os-release; suite="${VERSION_CODENAME:-}"; \
    # Rebuild sources.list for the current suite (works for modern releases)
    printf 'deb http://deb.debian.org/debian %s main\n' "$suite" > /etc/apt/sources.list; \
    printf 'deb http://deb.debian.org/debian %s-updates main\n' "$suite" >> /etc/apt/sources.list; \
    printf 'deb http://security.debian.org/debian-security %s-security main\n' "$suite" >> /etc/apt/sources.list; \
    # Try normal update first; on failure, fall back to the Debian archive
    if ! apt-get update; then \
    echo "Falling back to archive.debian.org for EOL suite: $suite"; \
    sed -ri 's@deb\.debian\.org@archive.debian.org@g; s@security\.debian\.org@archive.debian.org@g' /etc/apt/sources.list; \
    # Archived metadata is expired; disable Valid-Until to let apt use it
    printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    apt-get -o Acquire::Check-Valid-Until=false update; \
    fi

RUN apt-get update && \
    apt-get install -y \
    bash \
    openssh-client \
    wget \
    supervisor \
    curl \
    bc \
    gcc \
    libc-dev \
    libpq5 \
    libpq-dev \
    libaugeas-dev \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    ca-certificates \
    dialog \
    git \
    make

RUN apt-get install -y \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7-dev \
    libtiff5-dev \
    tk-dev \
    tcl-dev

# Upgrade pip
RUN pip install --upgrade pip

# Install pipenv
RUN pip install pipenv

# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push

RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /start.sh

RUN mkdir /app
CMD ["/start.sh"]
