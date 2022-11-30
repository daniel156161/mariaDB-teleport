FROM mariadb:latest

ENV TZ=Europe/Vienna
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y curl

RUN curl https://apt.releases.teleport.dev/gpg \
  -o /usr/share/keyrings/teleport-archive-keyring.asc

RUN export VERSION_CODENAME=jammy && echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
  https://apt.releases.teleport.dev/ubuntu ${VERSION_CODENAME?} stable/v11" \
  | tee /etc/apt/sources.list.d/teleport.list > /dev/null

RUN apt-get update && apt-get install -y teleport

VOLUME /var/lib/mysql
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mariadbd"]
