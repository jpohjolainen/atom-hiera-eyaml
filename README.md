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
Encrypting or decrypting multiple selections is also working.

You can create keys using Command Pallette and find `Hiera Eyaml: Create Keys`.
You are asked the directory where `keys/` will be created with public and
private keys. Default is Git repository or project's directory but this can be
changed in the config to a fixed directory.

It is possible to define direct paths seperately to public and private key.

Also wrapping is an option:

```yaml
---
  password: >
    ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBAD
    AFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEACvmEx6+xIWPpykTAsoFyCHb0MC
    +BWQPsWSm6yeJRgkWV+ZVhWwqz09nS1LMo6aKInzg2EjsDScpUFKeXvgxvV8
    IF9Bes33V5ySwnlDR15UAWWkfyYxpjk8ozSTGyIWATRITSMWOZDzOZRBYFcD
    Mj57o5kykkurVqskYG9DDQ8xPq85t2pPPHjb0d/BzJaeqqXsnacDrylbLJau
    +Ohldb+s/ekBwj/iDIu2NL3KvRvn2VxYAXrgehi9VXFutN6E8yoE72XkSxfN
    gBdUNtha3DF9jOjdTx3b43WesqNfAwyFvZ2IRCUzV4K1ZvIDK2pA8bsQDbuP
    XkX7r2fSgG4CUK4jA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBBo6hA3GV
    eKTzUgflmH0h9EgBCBe7XgD7ZVLBu3j6YhgL/I]
```

New on 0.4.0:
  You can choose to either indent only one level deeper when outputting a
  block, or indent to the column where selection starts.

  Encryption now removed quotes around strings.

### Hiera-eyaml keymaps
>- `Ctrl-Alt-E` to encrypt selection
>- `Ctrl-Alt-D` to decrypt selection
