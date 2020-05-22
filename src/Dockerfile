FROM ruby:2.6 as devbox

ARG WORK_DIR
ENV WORK_DIR "${WORK_DIR:-/workspace}"

ARG GROUP_ID=1000
ARG GROUP_NAME=dev
ARG USER_ID=1000
ARG USER_NAME=dev

ENV LANG C.UTF-8

ARG NODE_VERSION=12
ARG PYTHON_VERSION=3.7.3-1
ARG PIP_VERSION=18.1-5
ARG AWS_CLI_VERSION=1.18.52
ARG TERRAFORM_VERSION=0.12.25
ARG VAULT_VERSION=1.4.1

ARG OPENJDK_VERSION=11
ARG OPENJDK_BUILD=11+28
ENV JAVA_HOME "/opt/openjdk-${OPENJDK_VERSION}"
ENV PATH "${JAVA_HOME}/bin:$PATH"

ARG GRADLE_VERSION=6.4.1
ENV GRADLE_HOME "/opt/gradle"
ARG MAVEN_VERSION=3.6.3
ENV MAVEN_HOME "/opt/maven"
ENV MAVEN_CONFIG "/home/${USER_NAME}/.m2"
ARG FLYWAY_VERSION=6.4.2
ENV FLYWAY_HOME "/opt/flyway"

LABEL \
  "id"="com.seantrane.devbox" \
  "name"="DevBox" \
  "version"="1.0.0" \
  "description"="A portable shell environment and toolkit for software/ops engineers, using Docker." \
  "maintainer"="https://github.com/seantrane" \
  "repository"="https://github.com/seantrane/devbox" \
  "issues"="https://github.com/seantrane/devbox/issues" \
  "license"="ISC" \
  "build_timestamp"="$(date +%s)"

SHELL ["/bin/bash", "-c"]

RUN set -x \
  && echo -e "\n\n USER ❯ ${USER:-$(id -un || echo "\u")} @ ${HOST:-${HOSTNAME:-$(hostname || echo "\h")}} (${LANG:-}) \n\n SYSTEM ❯ ${UMACH:-${MACHTYPE:-$(uname -m || echo "")}} \n\n SHELL ❯ $(${SHELL:-} --version | head -n 1) \n\n" \
  # Add non-root user/group.
  && groupadd -r -g "${GROUP_ID}" "${GROUP_NAME}" \
  && useradd -r -g "${GROUP_NAME}" -u "${USER_ID}" -m -s "/bin/bash" "${USER_NAME}" \
  && cat "/etc/passwd" \
  && ls -lahF --time-style=long-iso --color "/home" \
  && ls -lahF --time-style=long-iso --color "/home/${USER_NAME}" \
  \
  # Install core dependencies.
  && apt-get update && apt-get install --no-install-recommends --no-install-suggests -yq \
    apt-utils \
    automake \
    build-essential \
    ca-certificates \
    g++ \
    gcc \
    gnupg \
    make \
    sudo \
  && rm -rf /var/lib/apt/lists/* \
  \
  # Install system dependencies.
  && apt-get update && apt-get install --no-install-recommends --no-install-suggests -yq \
    ack \
    bash \
    bash-completion \
    bash-doc \
    curl \
    dnsutils \
    git \
    git-lfs \
    grc \
    jq \
    mercurial \
    openssh-client \
    openssh-server \
    p7zip \
    shellcheck \
    subversion \
    tree \
    unzip \
    zip \
  && rm -rf /var/lib/apt/lists/* \
  \
  # Set Bash as default shell.
  && sed -i -e "s/bin\/sh/bin\/bash/" /etc/passwd \
  && cat "/etc/passwd" \
  && command -v bash && bash --version \
  \
  && git clone "https://github.com/bats-core/bats-core.git" /tmp/bats-core \
  && /tmp/bats-core/install.sh /usr/local \
  && rm -rf /tmp/bats-core \
  \
  # Install Java/OpenJDK, Maven and Gradle.
  && mkdir -p "${JAVA_HOME}" \
  && curl -OsL "https://download.java.net/openjdk/jdk${OPENJDK_VERSION}/ri/openjdk-${OPENJDK_BUILD}_linux-x64_bin.tar.gz" \
  && tar -xzf "openjdk-${OPENJDK_BUILD}_linux-x64_bin.tar.gz" -C "${JAVA_HOME}" --strip-components 1 --no-same-owner \
  && rm -f "openjdk-${OPENJDK_BUILD}_linux-x64_bin.tar.gz" \
  && for file in ${JAVA_HOME}/bin/*; do ln -s "${file}" "/usr/bin/$(basename "${file%.*}")"; done \
  && ( \
    find "${JAVA_HOME}/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > "/etc/ld.so.conf.d/docker-openjdk.conf"; \
    ldconfig; \
  ) \
  && command -v java && java --version \
  \
  && mkdir -p "${GRADLE_HOME}" \
  && curl -OsL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
  && unzip "gradle-${GRADLE_VERSION}-bin.zip" -d "${GRADLE_HOME}" \
  && rm -f "gradle-${GRADLE_VERSION}-bin.zip" \
  && ln -s "${GRADLE_HOME}/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
  && command -v gradle && gradle --version \
  \
  && mkdir -p "${MAVEN_HOME}" "${MAVEN_HOME}/ref" \
  && curl -OsL "https://apache.osuosl.org/maven/maven-${MAVEN_VERSION:0:1}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
  && tar -xzf "apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C "${MAVEN_HOME}" --strip-components=1 \
  && rm -f "apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
  && ln -s "${MAVEN_HOME}/bin/mvn" /usr/bin/mvn \
  && command -v mvn && mvn --version \
  \
  && mkdir -p "${FLYWAY_HOME}" \
  && curl -OsL "https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz" \
  && tar -xzf "flyway-commandline-${FLYWAY_VERSION}.tar.gz" -C "${FLYWAY_HOME}" --strip-components=1 \
  && rm -f "flyway-commandline-${FLYWAY_VERSION}.tar.gz" \
  && ln -s "${FLYWAY_HOME}/flyway" /usr/bin/flyway \
  && command -v flyway \
  \
  # Install Node.js/npm.
  && curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo -E bash - \
  && sudo apt-get install --no-install-recommends --no-install-suggests -yq \
    nodejs \
  && rm -rf /var/lib/apt/lists/* \
  && command -v node && node --version \
  && command -v npm && npm --version \
  \
  # Install AWS-CLI, Python 3, Terraform and Vault.
  && apt-get update && apt-get install --no-install-recommends --no-install-suggests -yq \
    python3=${PYTHON_VERSION} \
    python3-pip=${PIP_VERSION} \
  && rm -rf /var/lib/apt/lists/* \
  \
  && pip3 install setuptools==46.1.3 \
  && pip3 install wheel==0.34.2 \
  && pip3 install pyyaml==5.3.1 \
  && pip3 install awscli==${AWS_CLI_VERSION} \
  \
  && curl -Os "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/bin \
  && rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && command -v terraform && terraform --version \
  \
  && curl -Os "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" \
  && unzip "vault_${VAULT_VERSION}_linux_amd64.zip" -d /usr/bin \
  && rm -f "vault_${VAULT_VERSION}_linux_amd64.zip" \
  && command -v vault && vault --version \
  \
  && ls -lahF --time-style=long-iso --color "/usr/bin" \
  \
  # Install user/app dependencies.
  && gem install \
    bundler \
    jekyll \
    travis \
    travis-lint \
  \
  && npm i -g --unsafe \
    @angular/cli \
    @nrwl/schematics \
    cucumber \
    generator-repo \
    gulp \
    markdownlint-cli \
    puppeteer \
    semver \
    serverless \
    sonarlint \
    typescript \
    yo \
  && npm cache clean -g -f < /dev/null 2> /dev/null \
  && echo "$(npm list -g --depth=0 < /dev/null 2> /dev/null)" \
  \
  # Create work directory.
  && mkdir -p "${WORK_DIR}" \
  && chown -R "${USER_NAME}:${GROUP_NAME}" "${WORK_DIR}" \
  && ls -lahF --time-style=long-iso --color "${WORK_DIR}/.." \
  ;

# Copy config/settings.
COPY "settings/maven-settings-docker.xml" "${MAVEN_HOME}/ref/settings-docker.xml"

# Copy dotfiles.
COPY --chown=${USER_NAME}:${GROUP_NAME} dotfiles "/home/${USER_NAME}/dotfiles/"

# Symlink dotfiles.
RUN set -x; \
  ls -lahFR --time-style=long-iso --color "/home/${USER_NAME}"; \
  for src in $(find -H "/home/${USER_NAME}/dotfiles" -maxdepth 2 -name "*.symlink" -not -path "*.git*"); do \
    symlink="/home/${USER_NAME}/.$(basename "${src%.*}")"; \
    [[ -f "${symlink}" ]] && mv "${symlink}" "${symlink}.backup"; \
    ln -s "$src" "${symlink}" \
      && chmod 755 "${symlink}" \
      && chown -R "${USER_NAME}:${GROUP_NAME}" "${symlink}"; \
  done; \
  ls -lahF --time-style=long-iso --color "${symlink}";

USER "${USER_NAME}"

WORKDIR "${WORK_DIR}"

VOLUME ["${WORK_DIR}"]

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bash"]
