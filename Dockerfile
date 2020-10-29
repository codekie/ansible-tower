# Ansible Tower Dockerfie
FROM centos:8

WORKDIR /opt

ENV ANSIBLE_TOWER_VER 3.7.0-4
ENV PG_DATA /var/lib/postgresql/9.6/main
ENV AWX_PROJECTS /var/lib/awx/projects
ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_EN:en"
ENV LANG "en_US.UTF-8"
ENV DEBIAN_FRONTEND "noninteractive"
ADD http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY inventory inventory

RUN dnf --enablerepo=PowerTools install -y perl-Locale-gettext \
                                           perl-Text-CharWidth \
                                           perl-Text-WrapI18N \
    && dnf clean all \
    && rm -rf /var/cache/yum

RUN yum install -y epel-release \
    && yum makecache \
    && yum install -y gnupg \
                      python3 \
                      ca-certificates \
                      debconf \
                      sudo \
                      langpacks-en \
                      glibc-all-langpacks \
    && yum clean all \
    && mkdir -p /var/log/tower \
    && tar xvf ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
    && rm -f ansible-tower-setup-${ANSIBLE_TOWER_VER}.tar.gz \
    && pip3 install ansible \
    && mv inventory ansible-tower-setup-${ANSIBLE_TOWER_VER}/inventory

RUN cd /opt/ansible-tower-setup-${ANSIBLE_TOWER_VER} \
    && ./setup.sh \
    && chmod +x /docker-entrypoint.sh

# volumes and ports
VOLUME ["${PG_DATA}", "${AWX_PROJECTS}", "/certs",]
EXPOSE 443

CMD ["/docker-entrypoint.sh", "ansible-tower"]
