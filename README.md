# `trombik.x509_certificate`

Manages X509 secret and/or public keys. The role assumes you already have valid
secret key or *signed* public key. The role does not create or manage CSR.

# Requirements

The role uses `ansible` collection. See [`requirements.yml`](requirements.yml).

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `x509_certificate_dir` | path to default directory to keep certificates and keys | `{{ __x509_certificate_dir }}` |
| `x509_certificate_packages` | list of packages to install to manage keys, i.e. validating certificates | `{{ __x509_certificate_packages }}` |
| `x509_certificate_default_owner` | default owner of keys | `{{ __x509_certificate_default_owner }}` |
| `x509_certificate_default_group` | default group of keys | `{{ __x509_certificate_default_group }}` |
| `x509_certificate_additional_packages` | list of additional packages to install. they are installed before managing certificates and keys. useful when the owner of the files does not exist, but to be created by other role or task later. using this variable needs care. when a package is installed by this role, package installation task after this role will not be triggered, which might cause unexpected effects. in that case, create the user and the group by yourself | `[]` |
| `x509_certificate_validate_command` | command to validate certificate and keys. the command must be defined in `x509_certificate_validate_command_secret` and `x509_certificate_validate_command_public` as key | `openssl` |
| `x509_certificate_validate_command_secret` | dict of command to validate secret key (see below) | `{"openssl"=>"openssl rsa -check -in %s"}` |
| `x509_certificate_validate_command_public` | dict of command to validate public key (see below) | `{"openssl"=>"openssl x509 -noout -in %s"}` |
| `x509_certificate` | keys to manage (see below) | `[]` |
| `x509_certificate_debug_log` | enable logging of sensitive data during the play if `yes`. note that the log will display the value of `x509_certificate`, including secret key, if `yes` | `no` |
| `x509_certificate_update_ca_store_command` | Command to run when root CA certificate store is updated | `{{ __x509_certificate_update_ca_store_command }}` |
| `x509_certificate_cfssl_scheme` | URL scheme part of `cfssl` URL | `https` |
| `x509_certificate_cfssl_host` | Host part of `cfssl` URL | `127.0.0.1` |
| `x509_certificate_cfssl_port` | Port of `cfssl` | `8888` |
| `x509_certificate_cfssl_endpoint_base_path` | Path part of `cfssl` URL | `/api/v1/cfssl` |
| `x509_certificate_cfssl_retries` | Number of retry when connecting to `cfssl` | `3` |
| `x509_certificate_cfssl_delay` | Delay in second between retry when connecting to `cfssl` | `10` |
| `x509_certificate_cfssl_uri_param` | Additional parameters in dict to pass `ansible` `uri` module when connecting `cfssl` | `{}` |
| `x509_certificate_cfssl_certificate_newcert` | A list of certificates to send to `cfssl`. See below | `[]` |
| `x509_certificate_cfssl_info` | See below | `[]` |
| `x509_certificate_commands` | See below | `[]` |

## `x509_certificate_validate_command_secret`

This variable is a dict. The key is command name and the value is used to
validate secret key files when creating.

## `x509_certificate_validate_command_public`

This variable is a dict. The key is command name and the value is used to
validate public certificate files when creating.

## `x509_certificate`

This variable is a list of dict. Keys and Values are explained below.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `name` | Descriptive name of keys | yes |
| `state` | one of `present` or `absent`. the role creates the key when `present` and removes the key when `absent` | yes |
| `public` | a dict that represents a public certificate | no |
| `secret` | a dict that represents a secret key | no |

### `public` and `secret` in `x509_certificate`

`public` and `secret` must contain a dict. The dict is explained below.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `path` | path to the file. if not defined, the file will be created under `x509_certificate_dir`, with `$name.pem` | no |
| `owner` | owner of the file (default is `x509_certificate_default_owner`) | no |
| `group` | group of the file (default is `x509_certificate_default_group`) | no |
| `mode` | permission of the file (default is `0444` when the file is a public certificate, `0400` when the file is a secet key) | no |
| `key` | the content of the key | no |
| `notify` | A string or a list of name of handler(s) to notify | no |

## `x509_certificate_commands`

This variable is a list of dict. Each list element is a kind of mixture of
`ansible.builtin.command` and `ansible.builtin.file`. The element is first
passed to `ansible.builtin.command`, which is expected to create a file, and
the file is fixed up with specified `owner`, `group`, and `mode`.

The variable is intended for arbitrary file format conversion, such as a
secret key in `PKCS#1` to another secret key in `PKCS#8`, which is used by
some application, such as Java for example.

The commands are executed at the end of tasks.

The operation is not atomic.

Accepted keys are:

| Name | Description | Mandatory? |
|------|-------------|------------|
| `cmd` | A command to run | Yes |
| `creates` | Path to file that the command to create | Yes |
| `owner` | Name of file owner | No |
| `group` | Name of file group | No |
| `mode` | file permission | No |
| `notify` | A string or a list of name of handler(s) to notify | No |

## `x509_certificate_cfssl_certificate_newcert`

As this variable is _very_ experimental, it is intentionally not documented
yet.

See an example at [`tests/serverspec/cfssl.yml`](tests/serverspec/cfssl.yml).

## `x509_certificate_cfssl_info`

Calls `info` API and retrieves a root CA certificate from `cfssl` server.

This variable is a list of dict. The keys in the dict are:

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `path` | Path to a file to keep the certificate. | yes |
| `body` | A dict of body parameters to send in the request | yes |
| `notify` | A list of handlers to notify when the certificate file is modified. Default is `Update root CA store` handler (see below) | no |

## `x509_certificate_update_ca_store_command`

This command is invoked in  `Update root CA store` handler with
`ansible.builtin.command`.

## `Update root CA store` handler

Notify `Update root CA store` handler when you add a CA certificate to
system's root CA certificate store.

This handler does not work on OpenBSD yet.

## Including `trombik.x509_certificate`

You may include the role from your tasks or roles. Use `vars` to define
specific role variables by `vars`.

```yaml
- name: Include role trombik.x509_certificate
  include_role:
    name: trombik.x509_certificate
  vars:
    x509_certificate: "{{ my_valiable }}"
    x509_certificate_debug_log: yes
```

However, when you want to pass a single variable that includes the role
variables, you need to pass your variable to a special bridge role variable,
`x509_certificate_vars`.

```yaml
- name: Include role trombik.x509_certificate
  include_role:
    name: trombik.x509_certificate
  vars:
    x509_certificate_vars: "{{ my_variable }}"
```

The following example does NOT work:

```yaml
- name: Include role trombik.x509_certificate
  include_role:
    name: trombik.x509_certificate
  vars: "{{ my_variable }}"
```

See [Issue 19084](https://github.com/ansible/ansible/issues/19084) for the
details.

## Debian

| Variable | Default |
|----------|---------|
| `__x509_certificate_dir` | `/etc/ssl` |
| `__x509_certificate_packages` | `["openssl"]` |
| `__x509_certificate_default_owner` | `root` |
| `__x509_certificate_default_group` | `root` |

## Debian

| Variable | Default |
|----------|---------|
| `__x509_certificate_dir` | `/etc/ssl` |
| `__x509_certificate_packages` | `["openssl"]` |
| `__x509_certificate_default_owner` | `root` |
| `__x509_certificate_default_group` | `root` |
| `__x509_certificate_update_ca_store_command` | `update-ca-certificates` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__x509_certificate_dir` | `/usr/local/etc/ssl` |
| `__x509_certificate_packages` | `[]` |
| `__x509_certificate_default_owner` | `root` |
| `__x509_certificate_default_group` | `wheel` |
| `__x509_certificate_update_ca_store_command` | `/usr/sbin/certctl rehash` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__x509_certificate_dir` | `/etc/ssl` |
| `__x509_certificate_packages` | `[]` |
| `__x509_certificate_default_owner` | `root` |
| `__x509_certificate_default_group` | `wheel` |
| `__x509_certificate_update_ca_store_command` | `echo` |

## RedHat

| Variable | Default |
|----------|---------|
| `__x509_certificate_dir` | `/etc/ssl` |
| `__x509_certificate_packages` | `["openssl"]` |
| `__x509_certificate_default_owner` | `root` |
| `__x509_certificate_default_group` | `root` |
| `__x509_certificate_update_ca_store_command` | `update-ca-trust` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  pre_tasks:
    - name: Install rsyslog on Fedora
      ansible.builtin.yum:
        name: rsyslog
        state: installed
      when:
        - ansible_distribution == 'Fedora'
    - name: Enable rsyslog
      ansible.builtin.service:
        name: rsyslog
        enabled: yes
      when:
        - ansible_distribution == 'Fedora'
    - name: Start rsyslog
      ansible.builtin.service:
        name: rsyslog
        state: started
      when:
        - ansible_distribution == 'Fedora'
  roles:
    - ansible-role-x509_certificate
  handlers:
    # XXX used only for tests
    - name: Restart foo
      command: "logger foo is notified"
    - name: Restart bar
      command: "logger bar is notified"
    - name: Restart buz
      command: "logger buz is notified"
    - name: Restart foobar
      command: "logger foobar is notified"
  vars:
    os_project_some_user:
      FreeBSD: www
      Debian: www-data
      RedHat: ftp
      OpenBSD: www
    project_some_user: "{{ os_project_some_user[ansible_os_family] }}"
    os_project_some_group:
      FreeBSD: www
      Debian: www-data
      RedHat: ftp
      OpenBSD: www
    project_some_group: "{{ os_project_some_group[ansible_os_family] }}"

    os_project_quagga_cert_dir:
      FreeBSD: /usr/local/etc/quagga/certs
      OpenBSD: /etc/quagga/certs
      Debian: /etc/quagga/certs
      RedHat: /etc/quagga/certs
    project_quagga_cert_dir: "{{ os_project_quagga_cert_dir[ansible_os_family] }}"
    os_project_quagga_user:
      FreeBSD: quagga
      Debian: quagga
      RedHat: quagga
      OpenBSD: _quagga
    project_quagga_user: "{{ os_project_quagga_user[ansible_os_family] }}"
    os_project_quagga_group:
      FreeBSD: quagga
      Debian: quagga
      RedHat: quagga
      OpenBSD: _quagga
    project_quagga_group: "{{ os_project_quagga_group[ansible_os_family] }}"

    # XXX NEVER set this variable to `yes` unless you know what you are doing.
    x509_certificate_debug_log: yes

    x509_certificate_additional_packages:
      - quagga
    x509_certificate:
      - name: foo
        state: present
        public:
          notify:
            - Restart foo
            - Restart buz
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
          owner: "{{ project_some_user }}"
          group: "{{ project_some_group }}"
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
          owner: "{{ project_some_user }}"
          group: "{{ project_some_group }}"
          notify: Restart bar
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
      - name: quagga
        state: present
        public:
          path: "{{ project_quagga_cert_dir }}/quagga.pem"
          owner: "{{ project_quagga_user }}"
          group: "{{ project_quagga_group }}"
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
          path: "{{ project_quagga_cert_dir }}/quagga.key"
          owner: "{{ project_quagga_user }}"
          group: "{{ project_quagga_group }}"
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

    x509_certificate_commands:
      # XXX libressl does not work with `-out -`, and the argument of -inform must
      # be lower-cased.
      - cmd: "openssl pkcs8 -inform pem -outform pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -in {{ project_quagga_cert_dir }}/quagga.key -out {{ project_quagga_cert_dir }}/pkcs8.key"
        creates: "{{ project_quagga_cert_dir }}/pkcs8.key"
        owner: "{{ project_quagga_user }}"
        group: "{{ project_quagga_group }}"
        mode: "0440"
        notify: Restart foobar
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

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

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
