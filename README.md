# Docker DevBox

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

The Docker DevBox is a portable shell environment and toolkit for software/ops engineers, using Docker.

It contains many of the _typical_ dependencies that a full-stack engineer uses on a regular basis.
It is meant to be forked and manicured to whatever liking an individual wishes, as everyone has their own unique preferences.

## Install <a id="install"></a>

```sh
# 1. Clone repo in a directory you feel comfortable with.
#    These instructions use the "$HOME" directory.
git clone https://github.com/seantrane/devbox.git "$HOME/devbox"
# 2. Create aliases in your ".profile" or ".zshenv" file
#    that resolve to the DevBox binaries.
echo "alias devbox='$HOME/devbox/bin/devbox'" >> "$HOME/.profile"
echo "alias devboxd='$HOME/devbox/bin/devbox_remove'" >> "$HOME/.bashrc"
# 3. Restart your shell environment.
```

## Usage <a id="usage"></a>

```sh
# 1. Run any binary (from the DevBox) in your current directory.
devbox aws --version
# 2. Launch the DevBox container, mounting your
#    current directory to the DevBox "/workspace" directory.
devbox
# 3. The DevBox has many built-in aliases and shortcuts.
#    Aliases can only be accessed inside the container,
#    because "exec" command doesn't know they exist.
la # =>  ls -lahF --color --time-style=long-iso
.. # =>  cd ..
... # =>  cd ../..
.... # =>  cd ../../..
# 4. Shell environment enhancements, such as aliases,
#    can be found/configured in the "src/dotfiles" directory.
```

---

## Support <a id="support"></a>

[Submit an issue](https://github.com/seantrane/devbox/issues/new), in which you should provide as much detail as necessary for your issue.

## Contributing <a id="contributing"></a>

Contributions are always appreciated. Read [CONTRIBUTING.md](https://github.com/seantrane/devbox/blob/master/CONTRIBUTING.md) documentation to learn more.

## Changelog <a id="changelog"></a>

Release details are documented in the [CHANGELOG.md](https://github.com/seantrane/devbox/blob/master/CHANGELOG.md) file, and on the [GitHub Releases page](https://github.com/seantrane/devbox/releases).

---

## License <a id="license"></a>

[ISC License](https://github.com/seantrane/devbox/blob/master/LICENSE)

Copyright (c) 2020 [Sean Trane Sciarrone](https://github.com/seantrane)
