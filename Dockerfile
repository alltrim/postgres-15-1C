FROM ubuntu:22.04

ENV TZ Europe/Kiev
ARG POSTGRES_PASSWORD=postgres

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i uk_UA -c -f UTF-8 -A /usr/share/locale/locale.alias uk_UA.UTF-8

ENV LANG uk_UA.utf8

RUN apt-get update && apt-get install -y wget libxt6 net-tools

RUN wget https://repo.postgrespro.ru/1c-15/keys/pgpro-repo-add.sh \
    && sh pgpro-repo-add.sh && rm pgpro-repo-add.sh

RUN apt-get install -y postgrespro-1c-15 \
    && echo "ALTER ROLE postgres WITH PASSWORD '${POSTGRES_PASSWORD}';" > /password.sql \
    && chown postgres:postgres /password.sql \
    && su -l postgres -c "psql -f /password.sql"

RUN echo "#! /bin/bash" > start.sh \
    && echo "/etc/init.d/postgrespro-1c-15 start" >> start.sh \
    && echo "echo 'Is running...'" >> start.sh \
    && echo "while true; do sleep 1; done" >> start.sh \
    && chmod +x start.sh

VOLUME /var/lib/pgpro/1c-15/data
EXPOSE 5432

CMD [ "./start.sh" ]