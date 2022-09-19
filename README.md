# Instructions

Make sure you have `zola` installed on the machine:
- `brew install zola`

The minimum version:
- `zola`: `0.9.0`

## Update icons

Query the available icons
```bash
$ make static
$ rg '^.fa-var-(github|instagram):' tmp/fontawesome-free-6.2.0-web/scss/_variables.scss
$ rm tmp
```
