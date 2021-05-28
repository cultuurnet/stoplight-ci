# stoplight-ci

This repository is a collection of shell scripts that help automate the CI configuration of the various [stoplight-docs repositories](https://github.com/cultuurnet?q=stoplight-docs-&type=&language=&sort=) in the cultuurnet organization.

## configure-ci.sh

This script automatically adds the required config files and npm packages to a local clone of a `stoplight-docs` repository.

Usage:
```shell
$ ./configure-ci.sh [ <directory>]
```

- `directory`: The directory to execute the script in (optional)

**You do not need to clone this repository to use this script.** Instead, you can use this script using `curl` by executing the following command in the directory of your local clone of the stoplight-docs repository that should be configured:
```shell
# Clone the repository and change the active directory
$ git clone git@github.com:cultuurnet/stoplight-docs-uitpas.git
$ cd stoplight-docs-uitpas

$ bash <(curl -fsSL https://raw.githubusercontent.com/cultuurnet/stoplight-ci/main/configure-ci.sh)
```

⚠️ The script will only work in directories whose name starts with `stoplight-docs-`.
