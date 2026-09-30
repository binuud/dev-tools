# dev-tools
Tools for running a development environment

## install.sh

* Clone brew into home directory
* Create an python environment called ai

## zshrc

Add the following in .zshrc file on root directory
```
## source zshrc from dev-tools repo
source ~/[PATH]/dev-tools/zshrc
source ~/[PATH]/dev-tools/aliases
```



## Why not powershell or ohmysh

In some controlled environment, we cannot install any third party plugins, this is a straight implementation using zsh vanilla function.

Nerd font and fontawesome is used, you can remove the same if needed, in your fork. When using Terminal on macos, to use icons, select nerd font from the terminal settings.

## Sample commands

```
alias proxy-server="ssh -i ~/.ssh/[PEMFILE] -D [PROXY-PORT] -N [user@hostname]"
alias connect-server="ssh -i ~/.ssh/[PEMFILE] [user@hostname]"
```

## References
* [Ansii Font Control and Color Code](https://github.com/fidian/ansi)
* [Unicode Symbols](https://en.wikipedia.org/wiki/List_of_Unicode_characters#Cuneiform)