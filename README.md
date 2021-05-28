# stoplight-ci

This repository is a collection of shell scripts that help automate the CI configuration of the various [stoplight-docs repositories](https://github.com/cultuurnet?q=stoplight-docs-&type=&language=&sort=) in the cultuurnet organization.

## configure-ci.sh

This script automatically adds the required config files and npm packages to a local clone of a stoplight-docs repository.

Usage:
```shell
$ ./configure-ci.sh <project-name> [ <directory>]
```

- `project-name`: The name of the Stoplight project. For example, if your Stoplight project's repository is `stoplight-docs-uitpas` and the Stoplight url is https://publiq.stoplight.io/docs/uitpas, the name should be `uitpas`.
- `directory`: The directory to execute the script in (optional)

You can use this script using `curl` by executing the following command in the directory of your local clone of the stoplight-docs repository that should be configured:
```shell
# Clone the repository and change the active directory
$ git clone git@github.com:cultuurnet/stoplight-docs-uitpas.git
$ cd stoplight-docs-uitpas

$ bash <(curl -fsSL https://raw.githubusercontent.com/cultuurnet/stoplight-ci/main/configure-ci.sh) uitpas
```

⚠️ **Make sure to change the name argument at the end of the last line!**
