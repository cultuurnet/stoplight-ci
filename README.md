# Warning! ⚠️

This repository has been archived and is replaced by CI scripts in a new monorepo for all API documentation at https://github.com/cultuurnet/apidocs

---

# stoplight-ci

This repository is a collection of shell scripts that help automate the CI configuration of the various [stoplight-docs repositories](https://github.com/cultuurnet?q=stoplight-docs-&type=&language=&sort=) in the cultuurnet organization.

## requirements

- node, specifically with npm 7+ (use nvm to switch to node 15+)
- yarn 1

## configure-ci.sh

This script automatically adds the required config files and npm packages to a local clone of a `stoplight-docs` repository.

It will add/update the following `npm` packages through `yarn`:

- `@stoplight/spectral` to lint OpenAPI files
- `remark-cli` to lint Markdown files
- `remark-preset-lint-recommended` to lint Markdown files for common errors
- `remark-lint-no-dead-urls` to check for dead external URLs in Markdown files
- `remark-validate-links` to check for dead internal links in Markdown files

If the git repository didn't ignore the `node_modules` folder yet, it will be added to `.gitignore`.

Additionally, it adds/overwrites the following files:

- `.spectral.json` to configure the Spectral rulesets
- `.remarkrc` to configure the Remark rulesets
- `.github/workflows/ci.yml` to run Spectral and Remark in GitHub Actions
- `.github/pull_request_template.md` to provide a template for PRs
- `README.md` to provide documentation about how to make changes to Stoplight documentation repositories

It also provides the following `yarn` scripts to easily run the linting yourself inside the target repository:

- `api:lint` to lint OpenAPI files in the `/reference` directory of the repository
- `docs:lint` to lint Markdown files in the `/docs` directory of the repository
- `docs:lint:fix` to attempt to automatically fix errors in said Markdown files

Usage:
```shell
$ ./configure-ci.sh [ <directory>]
```

- `directory`: The directory to execute the script in (optional). If not provided, the script will be executed in the current directory.

**You do not need to clone this repository to use this script.** Instead, you can use this script using `curl` by executing the following command in the directory of your local clone of the stoplight-docs repository that should be configured:
```shell
# Clone the repository and change the active directory
$ git clone git@github.com:cultuurnet/stoplight-docs-uitpas.git
$ cd stoplight-docs-uitpas

# Download and execute the config-ci.sh script
$ bash <(curl -fsSL https://raw.githubusercontent.com/cultuurnet/stoplight-ci/main/configure-ci.sh)
```

⚠️ The script will only work in directories whose name starts with `stoplight-docs-`.

## configure-repository.sh

Use this script to run `configure-ci.sh` in a repository that you don't have a local clone of.

It will check out a given repository URL, run `configure-ci.sh` in it, commit any changes to a given branch, and push the branch. 
Afterward it will remove the checked out repository again. 

Usage:
```shell
$ ./configure-repository.sh <repository-url> <branch-name>
```

- `repository-url`: Git URL of the repository to clone. Can be either an HTTPS or SSH URL, depending on what you normally use. For example `git@github.com:cultuurnet/stoplight-docs-uitpas.git`.
- `branch-name`: The name of the branch to commit and push changes to (if there are any). Can be an existing or new branch.

To use this script you have to make a clone of this repository (`cultuurnet/stoplight-ci`) and execute it inside the checked out directory.

## configure-all-repositories.sh

Runs `configure-repository.sh` for a list of all known `stoplight-docs` repositories in the cultuurnet organization. 
Will display the full list and ask for confirmation first. 

If you do not want to update a specific repository, you can run the script for all repositories and simply delete the branch with the changes in the specific repository that should not be updated (yet).

Usage:
```shell
$ ./configure-all-repositories.sh <branch-name>
```

- `branch-name`: The name of the branch to commit and push changes to (if there are any). Can be an existing or new branch.

To use this script you have to make a clone of this repository (`cultuurnet/stoplight-ci`) and execute it inside the checked out directory.
