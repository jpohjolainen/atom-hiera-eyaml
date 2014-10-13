# hiera-eyaml package

Package to use hiera-eyaml commands in atom.

## Install

You need to install hiera-eyaml for this to work

```shell
gem install hiera-eyaml
```

## Usage

You can encrypt or decrypt selected text with hiera-eyaml using keymaps
 `Ctrl-Alt-E` or `Ctrl-Alt-D`. Keys are searched from `keys` directory under
 Git repository root, project directory or directory the edited file is.

You can create keys using Command Pallette and find `Hiera Eyaml: Create Keys`.
You are asked the directory where `keys/` will be created with public and
private keys.




### Hiera-eyaml keymaps
>- `Ctrl-Alt-E` to encrypt selection
>- `Ctrl-Alt-D` to decrypt selection
