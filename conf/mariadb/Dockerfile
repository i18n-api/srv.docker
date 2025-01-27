FROM mariadb:11

RUN \
apt-get update &&\
apt-get install -y mariadb-plugin-rocksdb &&\
rm -rf /var/cache/apt/lists/* &&\
chown -R mysql /etc/mysql 

ADD init.cnf /etc/mysql/conf.d/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mariadbd"]

