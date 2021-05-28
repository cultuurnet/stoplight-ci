# stoplight-ci

This repository is a collection of shell scripts that help automate the CI configuration of the various [stoplight-docs repositories](https://github.com/cultuurnet?q=stoplight-docs-&type=&language=&sort=) in the cultuurnet organization.

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
