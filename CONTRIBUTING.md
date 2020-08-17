# Contributing

> Thank you for contributing. Contributions are always welcome, no matter how large or small.

## Table of Contents

- [Guidelines](#guidelines)
- [Pull Requests](#pull-requests)
- [Clone the Repository](#clone-repo)
- [Install Dependencies](#install-dependencies)
- [File Structure](#file-structure)

---

## Guidelines <a id="guidelines"></a>

As a contributor, here are the guidelines you should follow:

- [Code of conduct](https://github.com/seantrane/engineering/blob/master/CODE_OF_CONDUCT.md)
- [How can I contribute?](https://github.com/seantrane/engineering/blob/master/CONTRIBUTING.md#how-can-i-contribute)
- [Using the issue tracker](https://github.com/seantrane/engineering/blob/master/CONTRIBUTING.md#using-the-issue-tracker)
- [Submitting a Pull Request](https://github.com/seantrane/engineering/blob/master/CONTRIBUTING.md#submitting-a-pull-request)
- [Coding rules](https://github.com/seantrane/engineering/blob/master/CONTRIBUTING.md#coding-rules)
- [Working with code](https://github.com/seantrane/engineering/blob/master/CONTRIBUTING.md#working-with-code)

We also recommend to read [How to Contribute to Open Source](https://opensource.guide/how-to-contribute).

---

## Pull Requests <a id="pull-requests"></a>

Thank you for contributing.

- Create your branch from `master`.
- Ensure your [git commit messages follow the required format](https://github.com/seantrane/engineering/blob/master/STYLE_GUIDES.md#git-commit-messages).
- Ensure your scripts are well-formed, well-documented and object-oriented.
- Ensure your scripts are stateless and can be reused by all.
- Update your branch, and resolve any conflicts, before making pull request.
- Fill in [the required template](https://github.com/seantrane/engineering/blob/master/PULL_REQUEST_TEMPLATE.md).
- Do not include issue numbers in the PR title.
- Include screenshots and animated GIFs in your pull request whenever possible.
- Follow the [style guide](https://github.com/seantrane/engineering/blob/master/STYLE_GUIDES.md) [applicable to the language](https://github.com/seantrane/engineering/blob/master/STYLE_GUIDES.md#languages) or task.
- Include thoughtfully-worded, well-structured tests/specs. See the [Tests/Specs Style Guide](https://github.com/seantrane/engineering/blob/master/STYLE_GUIDES.md#tests).
- Document new code based on the [Documentation Style Guide](https://github.com/seantrane/engineering/blob/master/STYLE_GUIDES.md#documentation).
- End all files with a newline.

---

## Clone the Repository <a id="clone-repo"></a>

```sh
git clone git@github.com:seantrane/runbox.git devbox && cd devbox
```

---

## File Structure <a id="file-structure"></a>

```text
devbox/
├─ .dependabot/                               * Dependabot config directory
├─ .github/                                   * GitHub config directory
│
├─ bin/                                       * Binaries directory
│  ├─ docker_functions.sh                     * Support functions for the RunBox CLI
│  └─ runbox                                  * RunBox CLI to create/destroy image and run container
│
├─ src/                                       * Source files directory
│  ├─ dotfiles/                               * Dotfiles directory
│  │  ├─ aliases.symlink                      * '~/.aliases' file
│  │  ├─ bash_env.symlink                     * '~/.bash_env' file
│  │  ├─ bash_login.symlink                   * '~/.bash_login' file
│  │  ├─ bash_profile.symlink                 * '~/.bash_profile' file
│  │  ├─ bash_prompt.symlink                  * '~/.bash_prompt' file
│  │  ├─ bashrc.symlink                       * '~/.bashrc' file
│  │  └─ paths.symlink                        * '~/.paths' file
│  │
│  ├─ settings/                               * Settings/config/prefs directory
│  │  └─ maven-settings-docker.xml
│  │
│  ├─ docker-entrypoint.sh                    * Bash docker-entrypoint file
│  ├─ Dockerfile.basebox                      * The BaseBox Dockerfile
│  ├─ Dockerfile.devbox                       * The DevBox Dockerfile
│  └─ Dockerfile.opsbox                       * The OpsBox Dockerfile
│
├─ .editorconfig                              * Keep developers/IDE's in sync
├─ .env.example                               * Environment configuration variables template
├─ .gitignore                                 * Ignore files for git
├─ .markdownlint.yaml                         * Markdown lint rules and config
├─ CODEOWNERS                                 * Default pull-request reviewers
├─ CONTRIBUTING.md                            * Contributing guidelines
└─ README.md                                  * Repository ReadMe file
```

---

#### Happy coding!
