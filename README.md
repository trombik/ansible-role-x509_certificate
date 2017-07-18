# ansible-role-x509-certs

Manages X509 secret and/or public keys. The role assumes you already have valid
secret key or *signed* public key. The role does not create or manage CSR.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `x509_certs_dir` | path to default directory to keep certificates and keys | `{{ __x509_certs_dir }}` |
| `x509_certs_packages` | list of packages to install to manage keys, i.e. validating certificates | `{{ __x509_certs_packages }}` |
| `x509_certs_default_owner` | default owner of keys | `{{ __x509_certs_default_owner }}` |
| `x509_certs_default_group` | default group of keys | `{{ __x509_certs_default_group }}` |
| `x509_certs_additional_packages` | list of additional packages to install. they are installed before managing certificates and keys. useful when the owner of the files does not exist, but to be created by other role or task later. using this variable needs care. when a package is installed by this role, package installation task after this role will not be triggered, which might cause unexpected effects. in that case, create the user and the group by yourself | `[]` |
| `x509_certs_validate_command` | command to validate certificate and keys. the command must be defined in `x509_certs_validate_command_secret` and `x509_certs_validate_command_public` as key | `openssl` |
| `x509_certs_validate_command_secret` | dict of command to validate secret key (see below) | `{"openssl"=>"openssl rsa -check -in %s"}` |
| `x509_certs_validate_command_public` | dict of command to validate public key (see below) | `{"openssl"=>"openssl x509 -noout -in %s"}` |
| `x509_certs` | keys to manage (see below) | `[]` |

## `x509_certs_validate_command_secret`

This variable is a dict. The key is command name and the value is used to
validate secret key files when creating.

## `x509_certs_validate_command_public`

This variable is a dict. The key is command name and the value is used to
validate public certificate files when creating.

## `x509_certs`

This variable is a list of dict. Keys and Values are explained below.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `name` | Descriptive name of keys | yes |
| `state` | one of `present` or `absent`. the role creates the key when `present` and removes the key when `absent` | yes |
| `public` | a dict that represents a public certificate | no |
| `secret` | a dict that represents a secret key | no |

### `public` and `secret` in `x509_certs`

`public` and `secret` must contain a dict. The dict is explained below.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `path` | path to the file. if not defined, the file will be created under `x509_certs_dir`, with `$name.pem` | no |
| `owner` | owner of the file (default is `x509_certs_default_owner`) | no |
| `group` | group of the file (default is `x509_certs_default_group`) | no |
| `mode` | permission of the file (default is `0444` when the file is a public certificate, `0400` when the file is a secet key) | no |
| `key` | the content of the key | no |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__x509_certs_dir` | `/usr/local/etc/ssl` |
| `__x509_certs_packages` | `[]` |
| `__x509_certs_default_owner` | `root` |
| `__x509_certs_default_group` | `wheel` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-x509-certs
  vars:
    x509_certs_additional_packages:
      - postfix
    x509_certs:
      - name: foo
        state: present
        public:
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDOjCCAiICCQDaGChPypIR9jANBgkqhkiG9w0BAQUFADBfMQswCQYDVQQGEwJB
            VTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0
            cyBQdHkgTHRkMRgwFgYDVQQDDA9mb28uZXhhbXBsZS5vcmcwHhcNMTcwNzE4MDUx
            OTAxWhcNMTcwODE3MDUxOTAxWjBfMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29t
            ZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRgwFgYD
            VQQDDA9mb28uZXhhbXBsZS5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
            AoIBAQDZ9nd1isoGGeH4OFbQ6mpzlldo428LqEYSH4G7fhzLMKdYsIqkMRVl1J3s
            lXtsMQUUP3dcpnwFwKGzUvuImLHx8McycJKwOp96+5XD4QAoTKtbl59ZRFb3zIjk
            Owd94Wp1lWvptz+vFTZ1Hr+pEYZUFBkrvGtV9BoGRn87OrX/3JI9eThEpksr6bFz
            QvcGPrGXWShDJV/hTkWxwRicMMVZVSG6niPusYz2wucSsitPXIrqXPEBKL1J8Ipl
            8dirQLsH02ZZKcxGctEjlVgnpt6EI+VL6fs5P6A45oJqWmfym+uKztXBXCx+aP7b
            YUHwn+HV4qzZQld80PSTk6SS3hMXAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAKgf
            x3K9GHDK99vsWN8Ej10kwhMlBWBGuM0wkhY0fbxJ0gW3sflK8z42xMc2dhizoYsY
            sLfN0aylpN/omocl+XcYugLHnW2q8QdsavWYKXqUN0neIMr/V6d1zXqxbn/VKdGr
            CD4rJwewBattCIL4+S2z+PKr9oCrxjN4i3nujPhKv/yijhrtV+USw1VwuFqsYaqx
            iScC13F0nGIJiUVs9bbBwBKn1c6GWUHHiFCZY9VJ15SzilWAY/TULsRsHR53L+FY
            mGfQZBL1nwloDMJcgBFKKbG01tdmrpTTP3dTNL4u25+Ns4nrnorc9+Y/wtPYZ9fs
            7IVZsbStnhJrawX31DQ=
            -----END CERTIFICATE-----
      - name: bar
        state: present
        public:
          path: /usr/local/etc/ssl/bar/bar.pub
          owner: www
          group: www
          mode: "0644"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDOjCCAiICCQDaGChPypIR9jANBgkqhkiG9w0BAQUFADBfMQswCQYDVQQGEwJB
            VTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0
            cyBQdHkgTHRkMRgwFgYDVQQDDA9mb28uZXhhbXBsZS5vcmcwHhcNMTcwNzE4MDUx
            OTAxWhcNMTcwODE3MDUxOTAxWjBfMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29t
            ZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRgwFgYD
            VQQDDA9mb28uZXhhbXBsZS5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
            AoIBAQDZ9nd1isoGGeH4OFbQ6mpzlldo428LqEYSH4G7fhzLMKdYsIqkMRVl1J3s
            lXtsMQUUP3dcpnwFwKGzUvuImLHx8McycJKwOp96+5XD4QAoTKtbl59ZRFb3zIjk
            Owd94Wp1lWvptz+vFTZ1Hr+pEYZUFBkrvGtV9BoGRn87OrX/3JI9eThEpksr6bFz
            QvcGPrGXWShDJV/hTkWxwRicMMVZVSG6niPusYz2wucSsitPXIrqXPEBKL1J8Ipl
            8dirQLsH02ZZKcxGctEjlVgnpt6EI+VL6fs5P6A45oJqWmfym+uKztXBXCx+aP7b
            YUHwn+HV4qzZQld80PSTk6SS3hMXAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAKgf
            x3K9GHDK99vsWN8Ej10kwhMlBWBGuM0wkhY0fbxJ0gW3sflK8z42xMc2dhizoYsY
            sLfN0aylpN/omocl+XcYugLHnW2q8QdsavWYKXqUN0neIMr/V6d1zXqxbn/VKdGr
            CD4rJwewBattCIL4+S2z+PKr9oCrxjN4i3nujPhKv/yijhrtV+USw1VwuFqsYaqx
            iScC13F0nGIJiUVs9bbBwBKn1c6GWUHHiFCZY9VJ15SzilWAY/TULsRsHR53L+FY
            mGfQZBL1nwloDMJcgBFKKbG01tdmrpTTP3dTNL4u25+Ns4nrnorc9+Y/wtPYZ9fs
            7IVZsbStnhJrawX31DQ=
            -----END CERTIFICATE-----
        secret:
          path: /usr/local/etc/ssl/bar/bar.key
          owner: www
          group: www
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEA2fZ3dYrKBhnh+DhW0Opqc5ZXaONvC6hGEh+Bu34cyzCnWLCK
            pDEVZdSd7JV7bDEFFD93XKZ8BcChs1L7iJix8fDHMnCSsDqfevuVw+EAKEyrW5ef
            WURW98yI5DsHfeFqdZVr6bc/rxU2dR6/qRGGVBQZK7xrVfQaBkZ/Ozq1/9ySPXk4
            RKZLK+mxc0L3Bj6xl1koQyVf4U5FscEYnDDFWVUhup4j7rGM9sLnErIrT1yK6lzx
            ASi9SfCKZfHYq0C7B9NmWSnMRnLRI5VYJ6behCPlS+n7OT+gOOaCalpn8pvris7V
            wVwsfmj+22FB8J/h1eKs2UJXfND0k5Okkt4TFwIDAQABAoIBAHmXVOztj+X3amfe
            hg/ltZzlsb2BouEN7okNqoG9yLJRYgnH8o/GEfnMsozYlxG0BvFUtnGpLmbHH226
            TTfWdu5RM86fnjVRfsZMsy+ixUO2AaIG444Y4as7HuKzS2qd5ZXS1XB8GbrCSq7r
            iF/4tscQrzoG0poQorP9f9y60+z3R45OX3QMVZxP4ZzxXAulHGnECERjLHM5QzTX
            ALV9PHkTRNd1tm9FSJWWGNO5j4CGxFsPL1kdMyvrC7TkYiIiCQ/dd2CIfQyWwyKc
            8cHBKnzon0ugr0xlf2B0C7RTXrGAcuBC0yyaLuQTFkocUofgDIFghItH8O8xvvAG
            j8HYOwECgYEA9uMLtm2C8SiWFuafrF/pPWvhkBtEHA2g22M29CANrVv1jCEVMti/
            7r53fd328/nVxtashnSFz7a3l3s9d9pTR/rk/rNpVS2i7JGvCXXE3DeoD6Zf4utD
            MLEs2bI0KabdamIywc77CkVj9WUKd53tlcdcn7AsHwESU4Zjk08ie0kCgYEA4gIa
            R+a9jmKEk9l5Gn7jroxDJdI0gEfuA7It5hshEDcSvjF+Fs5+1tVgfBI1Mx4/0Eaj
            6E57Ln3WFKPJKuG0HwLNanZcqLFgiC/7ANbyKxfONPVrqC2TClImBhkQ74BLafZg
            yY8/N/g/5RIMpYvQ9snBRsah9G2cBfuPTHjku18CgYBHylPQk12dJJEoTZ2msSkQ
            jDtF/Te79JaO1PXY3S08+N2ZBtG0PGTrVoVGm3HBFif8rtXyLxXuBZKzQMnp/Rl0
            d9d43NDHTQLwSZidZpp88s4y5s1BHeom0Y5aK0CR0AzYb3+U7cv/+5eKdvwpNkos
            4JDleoQJ6/TZRt3TqxI6yQKBgA8sdPc+1psooh4LC8Zrnn2pjRiM9FloeuJkpBA+
            4glkqS17xSti0cE6si+iSVAVR9OD6p0+J6cHa8gW9vqaDK3IUmJDcBUjU4fRMNjt
            lXSvNHj5wTCZXrXirgraw/hQdL+4eucNZwEq+Z83hwHWUUFAammGDHmMol0Edqp7
            s1+hAoGBAKCGZpDqBHZ0gGLresidH5resn2DOvbnW1l6b3wgSDQnY8HZtTfAC9jH
            DZERGGX2hN9r7xahxZwnIguKQzBr6CTYBSWGvGYCHJKSLKn9Yb6OAJEN1epmXdlx
            kPF7nY8Cs8V8LYiuuDp9UMLRc90AmF87rqUrY5YP2zw6iNNvUBKs
            -----END RSA PRIVATE KEY-----
      - name: postfix
        state: present
        public:
          path: /usr/local/etc/postfix/certs/postfix.pem
          owner: postfix
          group: mail
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDOjCCAiICCQDaGChPypIR9jANBgkqhkiG9w0BAQUFADBfMQswCQYDVQQGEwJB
            VTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0
            cyBQdHkgTHRkMRgwFgYDVQQDDA9mb28uZXhhbXBsZS5vcmcwHhcNMTcwNzE4MDUx
            OTAxWhcNMTcwODE3MDUxOTAxWjBfMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29t
            ZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRgwFgYD
            VQQDDA9mb28uZXhhbXBsZS5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
            AoIBAQDZ9nd1isoGGeH4OFbQ6mpzlldo428LqEYSH4G7fhzLMKdYsIqkMRVl1J3s
            lXtsMQUUP3dcpnwFwKGzUvuImLHx8McycJKwOp96+5XD4QAoTKtbl59ZRFb3zIjk
            Owd94Wp1lWvptz+vFTZ1Hr+pEYZUFBkrvGtV9BoGRn87OrX/3JI9eThEpksr6bFz
            QvcGPrGXWShDJV/hTkWxwRicMMVZVSG6niPusYz2wucSsitPXIrqXPEBKL1J8Ipl
            8dirQLsH02ZZKcxGctEjlVgnpt6EI+VL6fs5P6A45oJqWmfym+uKztXBXCx+aP7b
            YUHwn+HV4qzZQld80PSTk6SS3hMXAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAKgf
            x3K9GHDK99vsWN8Ej10kwhMlBWBGuM0wkhY0fbxJ0gW3sflK8z42xMc2dhizoYsY
            sLfN0aylpN/omocl+XcYugLHnW2q8QdsavWYKXqUN0neIMr/V6d1zXqxbn/VKdGr
            CD4rJwewBattCIL4+S2z+PKr9oCrxjN4i3nujPhKv/yijhrtV+USw1VwuFqsYaqx
            iScC13F0nGIJiUVs9bbBwBKn1c6GWUHHiFCZY9VJ15SzilWAY/TULsRsHR53L+FY
            mGfQZBL1nwloDMJcgBFKKbG01tdmrpTTP3dTNL4u25+Ns4nrnorc9+Y/wtPYZ9fs
            7IVZsbStnhJrawX31DQ=
            -----END CERTIFICATE-----
        secret:
          path: /usr/local/etc/postfix/certs/postfix.key
          owner: postfix
          group: mail
          mode: "0440"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEA2fZ3dYrKBhnh+DhW0Opqc5ZXaONvC6hGEh+Bu34cyzCnWLCK
            pDEVZdSd7JV7bDEFFD93XKZ8BcChs1L7iJix8fDHMnCSsDqfevuVw+EAKEyrW5ef
            WURW98yI5DsHfeFqdZVr6bc/rxU2dR6/qRGGVBQZK7xrVfQaBkZ/Ozq1/9ySPXk4
            RKZLK+mxc0L3Bj6xl1koQyVf4U5FscEYnDDFWVUhup4j7rGM9sLnErIrT1yK6lzx
            ASi9SfCKZfHYq0C7B9NmWSnMRnLRI5VYJ6behCPlS+n7OT+gOOaCalpn8pvris7V
            wVwsfmj+22FB8J/h1eKs2UJXfND0k5Okkt4TFwIDAQABAoIBAHmXVOztj+X3amfe
            hg/ltZzlsb2BouEN7okNqoG9yLJRYgnH8o/GEfnMsozYlxG0BvFUtnGpLmbHH226
            TTfWdu5RM86fnjVRfsZMsy+ixUO2AaIG444Y4as7HuKzS2qd5ZXS1XB8GbrCSq7r
            iF/4tscQrzoG0poQorP9f9y60+z3R45OX3QMVZxP4ZzxXAulHGnECERjLHM5QzTX
            ALV9PHkTRNd1tm9FSJWWGNO5j4CGxFsPL1kdMyvrC7TkYiIiCQ/dd2CIfQyWwyKc
            8cHBKnzon0ugr0xlf2B0C7RTXrGAcuBC0yyaLuQTFkocUofgDIFghItH8O8xvvAG
            j8HYOwECgYEA9uMLtm2C8SiWFuafrF/pPWvhkBtEHA2g22M29CANrVv1jCEVMti/
            7r53fd328/nVxtashnSFz7a3l3s9d9pTR/rk/rNpVS2i7JGvCXXE3DeoD6Zf4utD
            MLEs2bI0KabdamIywc77CkVj9WUKd53tlcdcn7AsHwESU4Zjk08ie0kCgYEA4gIa
            R+a9jmKEk9l5Gn7jroxDJdI0gEfuA7It5hshEDcSvjF+Fs5+1tVgfBI1Mx4/0Eaj
            6E57Ln3WFKPJKuG0HwLNanZcqLFgiC/7ANbyKxfONPVrqC2TClImBhkQ74BLafZg
            yY8/N/g/5RIMpYvQ9snBRsah9G2cBfuPTHjku18CgYBHylPQk12dJJEoTZ2msSkQ
            jDtF/Te79JaO1PXY3S08+N2ZBtG0PGTrVoVGm3HBFif8rtXyLxXuBZKzQMnp/Rl0
            d9d43NDHTQLwSZidZpp88s4y5s1BHeom0Y5aK0CR0AzYb3+U7cv/+5eKdvwpNkos
            4JDleoQJ6/TZRt3TqxI6yQKBgA8sdPc+1psooh4LC8Zrnn2pjRiM9FloeuJkpBA+
            4glkqS17xSti0cE6si+iSVAVR9OD6p0+J6cHa8gW9vqaDK3IUmJDcBUjU4fRMNjt
            lXSvNHj5wTCZXrXirgraw/hQdL+4eucNZwEq+Z83hwHWUUFAammGDHmMol0Edqp7
            s1+hAoGBAKCGZpDqBHZ0gGLresidH5resn2DOvbnW1l6b3wgSDQnY8HZtTfAC9jH
            DZERGGX2hN9r7xahxZwnIguKQzBr6CTYBSWGvGYCHJKSLKn9Yb6OAJEN1epmXdlx
            kPF7nY8Cs8V8LYiuuDp9UMLRc90AmF87rqUrY5YP2zw6iNNvUBKs
            -----END RSA PRIVATE KEY-----
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
