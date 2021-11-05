## Release 2.2.3

* ecd812f bugfix: support `notify` in x509_cfssl_certificate_newcert

## Release 2.2.2

* 95a4aea bugfix: allow to notify handlers

## Release 2.2.1

* 1a1c17b bugfix: use correct role name in README
* 1819c5e bugfix: fix a typo in README
* 80051df bugfix: use canonical prefix for cfssl-related vars
* 48d427d bugfix: accpet a single variable for all role variables

## Release 2.2.0

* 348705e feature: introduce experimental `x509_cfssl_certificate_newcert`

## Release 2.1.4

* 91270ca bugfix: support Devuan
* 90461ea bugfix: QA
* d0c8a5c bugfix: update box versions
* 22b788f bugfix: add publish action

## Release 2.1.3

* ade5c4a bugfix: fix unquoted argument for `default`

## Release 2.1.2

* 1312ae1 ci: add Github Actions workflows
* e5ec3ca bugfix: QA
* 90e4985 bugfix: add a test case for state: absent
* 616b54c [bugfix] fixed wrong fileending
* e8a6f3d [bugfix] fixed wrong variable

## Release 2.1.1

* 960a941 bugfix: QA
* e297c15 bugfix: update boxes
* 1b2fc93 bugfix: remove with_items from package modules

## Release 2.1.0

* cb2577b bugfix: s/python/python3/ on OpenBSD 6.5
* b7faebd bugfix: update supported platform versions
* 5dd032d bugfix: QA
* 6dfbc06 feature: support FreeBSD 11.2, Ubuntu 18.04

## Release 2.0.1

* 1804b09 bugfix: add role_name again to fix role name in galaxy

## Release 2.0.0

* 529cb76 bugfix backward-incompatible: rename role name
* e2d6673 bugfix: QA

Due to a breaking change in galaxy, the repository name has been changed. the
canonical role name is now:

```
trombik.x509_certificate
```

## Release 1.2.0

* e0b2bbf [feature] Support OpenBSD 6.3, drop EoLed releases (#5)

## Release 1.1.2

* 38b5b56 [bugfix] s/include/include_tasks/, requiring ansible 2.4 (#3)

## Release 1.1.1

* 1f0f5d9 [bugfix] bump rubocop to the latest

## Release 1.1.0

* 8c431ea [feature] support FreeBSD 11.1 and OpenBSD 6.2 (#11)
* 3075f59 [documentation][bugfix] update README (#9)

## Release 1.0.1

* 4c6f620 [bugfix] update meta (#6)

## Release 1.0.0

* Initial release
