FROM python:2.7-alpine3.6
MAINTAINER boro <docker@bo.ro>

# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push

RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /start.sh

RUN mkdir /app
CMD ["/start.sh"]