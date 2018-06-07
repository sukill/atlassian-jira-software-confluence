FROM alpine:3.7
# Configuration variables.
ENV JIRA_HOME		/var/atlassian/jira
ENV JIRA_INSTALL	/opt/atlassian/jira
ENV JAVA_HOME		/opt/java/
ENV JIRA_VERSION	7.10.0
ENV PATH $PATH:/opt/java/bin

# Install Oracle Java
# directory structure



# Install Java
RUN set -x \
    && apk add --update --no-cache curl xmlstarlet bash ttf-dejavu wget tar\
    && mkdir -p /opt/java \
    && chmod -R 700			${JAVA_HOME} \
    && chown -R daemon:daemon	${JAVA_HOME} \
    && wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz \
    && tar --directory "${JAVA_HOME}" --strip-components=1 --no-same-owner -zxvf *-linux-x64.tar.gz 

# glibc installation for alpine linux
# referenced from "https://github.com/jeanblanchard/docker-alpine-glibc/blob/master/Dockerfile"
ENV GLIBC_VERSION 2.27-r0

# Download and install glibc
RUN curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
    && curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" \
    && curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" \
    && apk add glibc-bin.apk glibc.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf \
    && rm -rf glc.apk glibc-bin.apk /var/cache/apk/*


# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.

RUN  mkdir -p				${JIRA_HOME} ${JIRA_INSTALL} "${JIRA_INSTALL}/conf/Catalina"\
    && chmod -R 700			${JIRA_HOME} ${JIRA_INSTALL} \
    && chown -R daemon:daemon	${JIRA_HOME} ${JIRA_INSTALL} \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-"${JIRA_VERSION}".tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && apk del curl tar wget \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs", "/opt/java"]

# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/jira

COPY "docker-entrypoint.sh" "/"
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
