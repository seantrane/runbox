# Docker RunBox

> A portable shell environment and toolkit for software/ops engineers, using Docker.

## Table of Contents

- [About](#about)
- [Install](#install)
- [Usage](#usage)
- [Support](#support)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

---

## About <a id="about"></a>

The **Docker RunBox** is a portable shell environment and toolkit for software/ops engineers, using Docker.

The primary benefits are:

- Encapsulate many _typical_ dependencies that software/ops engineers use on a regular basis.
- Expedite onboarding and reduce dependency demands on the host machine.
- Provide engineers with a shared environment for all command line operations.
- Provide engineers with a shared library of automation and shell scripts.

There are 3 default _RunBoxes_ that can be built and launched independently:

- BaseBox = `basebox` _Enhanced shell environment using Bash v4._
- DevBox = `devbox` _Enhanced shell + full suite of polyglot developer dependencies and IaC utilities._
- OpsBox = `opsbox` _Enhanced shell + Ops-related and Infrastructure-as-Code utilities._

The solution allows for many _RunBoxes_ to be created, as each _RunBox_ is an individual `Dockerfile`.

It is meant to be forked and manicured to whatever liking an individual wishes, as everyone has their own unique preferences.

### Features <a id="features"></a>

The **DevBox** is the flagship _RunBox_ and contains the following features:

- [AWS-CLI v2](https://docs.aws.amazon.com/cli/index.html) + [AWS-ADFS](https://github.com/venth/aws-adfs)
- [Bash v4](https://www.tldp.org/LDP/abs/html/bashver4.html) + [bash-completion](https://github.com/scop/bash-completion#readme)
- [Java](https://www.java.com/)
  - [Flyway](https://flywaydb.org/)
  - [Gradle](https://gradle.org/)
  - [Maven](https://maven.apache.org/)
  - [OpenJDK](https://openjdk.java.net/)
- [Python v2](https://docs.python.org/2.7/)
- [Python v3](https://docs.python.org/3/)
- [Node.js](https://nodejs.org) + [npm](https://www.npmjs.com/)
  - [Angular CLI](https://cli.angular.io/)
  - [Commitlint](https://commitlint.io/)
  - [Commitizen](https://commitizen.github.io/cz-cli/)
  - [Cucumber](https://cucumber.io/)
  - [Gulp](http://gulpjs.com/)
  - [Markdownlint](https://github.com/igorshubovych/markdownlint-cli)
  - [Nx CLI](https://nx.dev/)
  - [Puppeteer](https://pptr.dev/)
  - [SemVer](https://github.com/npm/node-semver#readme)
  - [SonarLint](https://www.sonarlint.org/)
  - [TypeScript](https://www.typescriptlang.org/)
  - [Yeoman](http://yeoman.io/)
- [Ruby](https://www.ruby-lang.org/en/)
  - [Bundler](https://bundler.io/)
  - [Jekyll](http://jekyllrb.com/)
  - [Travis CLI](https://github.com/travis-ci/travis.rb#readme)
- [Terraform](https://www.terraform.io/)
- [ShellCheck](https://www.shellcheck.net/) + [Bats-core](https://github.com/bats-core/bats-core#readme)
- [Vault](https://www.vaultproject.io/)

---

## Install <a id="install"></a>

### 1. Clone repo

Clone repo in a directory you feel comfortable with.
_These instructions use the `$HOME` directory/variable._

```sh
git clone https://github.com/seantrane/runbox.git "$HOME/runbox"
```

### 2. Run installer

Creates aliases in host machine's `.profile` file that resolve to the _RunBox_ binaries.

```sh
"$HOME/runbox/scripts/install"
```

### 3. Restart your shell environment

---

## Usage <a id="usage"></a>

If the Docker image has not been built, then it will automatically be built.

For these docs, `devbox` is the _RunBox_ used, but the behaviors are identical for all _RunBoxes_.

### Run any binary (from the _RunBox_) in your current directory

This command will launch the `devbox` container, run the binary-command, then terminate the container.

```sh
devbox bash --version
```

### Launch the _RunBox_ container

This will mount the current directory on the host machine to the `/mnt/pwd` directory in the RunBox Docker image.

This means the Docker container will have access to the host machine's file system, from the directory you choose to launch it from.

```sh
devbox
```

### The _RunBox_ has many built-in aliases and shortcuts

Aliases can only be accessed while inside the container, because the `exec` command doesn't know they exist.

> If you enter `la` command, after launching the container, you should see a list of directory contents from the host machine.

```sh
la       # =>  ls -lahF --color --time-style=long-iso
..       # =>  cd ..
...      # =>  cd ../..
....     # =>  cd ../../..

gac      # =>  git add -A && git commit -m
glog     # =>  List all Git commits

npmlistg # =>  List all global npm packages
npmlist  # =>  List all local npm packages
```

### Shell environment enhancements are enabled via `dotfiles`

Shell environment enhancements, such as aliases, can be found/configured in the [`src/dotfiles`](src/dotfiles) directory.

Every file in the `dotfiles` directory named `*.symlink` are symlinked to `$HOME/.*` files in the _RunBoxes_.
For example, `bash_profile.symlink` is symlinked to `$HOME/.bash_profile` in the _RunBox_.

---

## Support <a id="support"></a>

[Submit an issue](https://github.com/seantrane/runbox/issues/new), in which you should provide as much detail as necessary for your issue.

## Contributing <a id="contributing"></a>

Contributions are always appreciated. Read [CONTRIBUTING.md](https://github.com/seantrane/runbox/blob/master/CONTRIBUTING.md) documentation to learn more.

## Changelog <a id="changelog"></a>

Release details are documented in the [CHANGELOG.md](https://github.com/seantrane/runbox/blob/master/CHANGELOG.md) file, and on the [GitHub Releases page](https://github.com/seantrane/runbox/releases).

---

## License <a id="license"></a>

[ISC License](https://github.com/seantrane/runbox/blob/master/LICENSE)

Copyright (c) 2020 [Sean Trane Sciarrone](https://github.com/seantrane)
