FROM centos:7

LABEL maintainer="NGINX Controller Engineering"

# e.g '1234567890'
ARG API_KEY
ENV ENV_CONTROLLER_API_KEY=$API_KEY

# e.g https://<fqdn>:8443/1.4
ARG CONTROLLER_URL
ENV ENV_CONTROLLER_URL=$CONTROLLER_URL

# e.g True or False
ARG STORE_UUID=False
ENV ENV_CONTROLLER_STORE_UUID=$STORE_UUID

# e.g Instance location already defined in Controller
ARG LOCATION
ENV ENV_CONTROLLER_LOCATION=$LOCATION

# Download certificate (nginx-repo.crt) and key (nginx-repo.key) from the customer portal (https://cs.nginx.com)
# and copy to the build context
COPY nginx-repo.* /etc/ssl/nginx/
#COPY nginx-plus-api.conf /etc/nginx/conf.d/

# Install NAP
RUN set -ex \
  && yum -y update && yum -y upgrade \
  && yum -y install curl sudo vim procps ca-certificates gnupg wget binutils net-tools epel-release
#  && \
#  NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
#  found=''; \
#  for server in \
#    ha.pool.sks-keyservers.net \
#    hkp://keyserver.ubuntu.com:80 \
#    hkp://p80.pool.sks-keyservers.net:80 \
#    pgp.mit.edu \
#  ; do \
#    echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
#    gpg --keyserver "$server" --recv-keys "0x$NGINX_GPGKEY" && found=yes && break; \
#  done; \
#  test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \


RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.repo
RUN yum -y update && yum -y install app-protect-22+3.158.1-1.el7.ngx

  # Install Controller Agent
RUN curl -k -sS -L ${CONTROLLER_URL}/install/controller/ > install.sh \
  && sed -i 's/^assume_yes=""/assume_yes="-y"/' install.sh \


  # TODO: remove once launching agent using `service` has been handled in the install script
  && sed -i '/^# Unconditionally stop the agent service/,$d' install.sh \
  && sh ./install.sh -y

  # Add security flag for CAS
RUN sed -i  '/\[extensions\]/a security = True' /etc/controller-agent/agent.conf

# Forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx-controller/agent.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./entrypoint.sh /

EXPOSE 80

STOPSIGNAL SIGTERM

ENTRYPOINT ["sh", "/entrypoint.sh"]