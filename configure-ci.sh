#!/bin/bash

# Shell script that configures a stoplight-docs git repository so that it has the expected CI setup.
# Arguments:
# - Directory to execute this script in (optional)

# Function to print info messages
print_info_message () {
  echo "[stoplight-ci] $1"
}

# Function to print error messages
print_error_message () {
  MESSAGE=$(print_info_message "$1")
  echo -e "\033[31m$MESSAGE\033[0m"
  exit 1
}

# Function to print success messages
print_success_message () {
  MESSAGE=$(print_info_message "$1")
  echo -e "\033[32m$MESSAGE\033[0m"
}

# Function to check for errors and print an error message and quit, or print a success message
check_errors () {
  if [ ! $? -eq 0 ]; then
    print_error_message "$1"
  fi
  print_success_message "$2"
}

# Function to check if a given command exists
check_command_exists () {
  type "$1" > /dev/null 2>/dev/null
}

add_yarn_package () {
  print_info_message "Adding/updating yarn package $1@$2..."

  yarn add $1@"$2" > /dev/null 2> /dev/null
  if [ ! $? -eq 0 ]; then
    print_error_message "Could not add yarn package $1@$2!"
  fi

  yarn upgrade $1 > /dev/null 2> /dev/null
  if [ ! $? -eq 0 ]; then
    print_error_message "Could not upgrade yarn package $1@$2!"
  fi

  print_success_message "Successfully added/updated yarn package $1@$2!"
}

# If a directory is specified (as second argument), switch to it first
if [ $# -gt 0 ]
then
   print_info_message "Switching to directory $1"
   cd $1
fi
if [ ! $? -eq 0 ]; then
  print_error_message "Could not switch to directory $1"
fi

# Check that we're inside a stoplight-docs-... repository
DIR_NAME=${PWD##*/}
if [[ ! $DIR_NAME == stoplight-docs-* ]]; then
  print_error_message "Current directory is not a stoplight-docs directory ($DIR_NAME, should be stoplight-docs-...)!"
fi
NAME=${DIR_NAME#"stoplight-docs-"}

# Check that npm is available
if ! check_command_exists "npm"; then
  print_error_message "Npm not found. Please install node first https://nodejs.org/en/download/"
fi

# Check that yarn is available
if ! check_command_exists "yarn"; then
  print_error_message "Yarn not found. Please install yarn first https://classic.yarnpkg.com/en/docs/install/"
fi

# Add/update packages for linting
print_info_message "Installing/upgrading spectral and remark packages for linting..."

add_yarn_package "@stoplight/spectral" "^6.0.0-alpha3"
add_yarn_package "remark-cli" "^9.0.0"
add_yarn_package "remark-preset-lint-recommended" "^5.0.0"
add_yarn_package "remark-lint-no-dead-urls" "^1.1.0"
add_yarn_package "remark-validate-links" "^10.0.4"

print_success_message "Successfully installed linting packages!"

# Configure npm/yarn scripts
print_info_message "Configuring npm scripts..."
npm set-script "api:lint" "spectral lint ./reference/**/*.{json,yml,yaml} --fail-severity warn"  > /dev/null 2>/dev/null
npm set-script "docs:lint" "remark ./docs/ --frail"  > /dev/null 2>/dev/null
npm set-script "docs:lint:fix" "remark ./docs/ --frail -o"  > /dev/null 2>/dev/null

check_errors "Could not configure npm scripts through set-script! Please make sure you are using npm v7.0.0 or higher" \
 "Successfully configured npm scripts!"

# Configure .gitignore
print_info_message "Configuring .gitignore"
touch .gitignore
grep -qxF "node_modules" .gitignore || echo "node_modules" >> .gitignore
check_errors "Could not configure .gitignore!" \
 "Successfully configured .gitignore!"

# Configure remark
print_info_message "Configuring remark..."
touch .remarkrc
cat <<REMARKRC >.remarkrc
{
  "plugins": [
    "remark-preset-lint-recommended",
    "remark-lint-no-dead-urls",
    "remark-validate-links"
  ]
}
REMARKRC
check_errors "Failed to configure remark!" \
 "Successfully configured remark!"

# Configure spectral
print_info_message "Configuring spectral..."
touch .spectral.json
cat <<SPECTRALJSON >.spectral.json
{
  "extends": "spectral:oas",
  "formats": ["oas3"],
  "rules": {
    "alphabetical-tags": {
      "description": "Tags should be sorted alphabetically",
      "given": "$",
      "then": {
        "field": "tags",
        "function": "alphabetical",
        "functionOptions": {
          "keyedBy": "name"
        }
      },
      "severity": "error"
    }
  }
}
SPECTRALJSON
check_errors "Failed to configure spectral!" \
 "Successfully configured spectral!"

# Configure GitHub Actions
print_info_message "Configuring GitHub Actions..."
mkdir .github > /dev/null 2> /dev/null
mkdir .github/workflows > /dev/null 2> /dev/null
if [ ! -d ./.github/workflows ]; then
  print_error_message "Directory ./.github/workflows does not exist and could not be created!"
fi

touch ./.github/workflows/ci.yml
cat <<CI >./.github/workflows/ci.yml
name: CI

on: push

jobs:
    openapi:
        runs-on: ubuntu-latest

        steps:
            - name: Checkout
              uses: actions/checkout@v2

            - name: Lint OpenAPI file(s)
              run: yarn && yarn api:lint

    docs:
        runs-on: ubuntu-latest

        steps:
            -   name: Checkout
                uses: actions/checkout@v2

            -   name: Lint Markdown docs
                run: yarn && yarn docs:lint

CI
check_errors "Could not configure GitHub Actions!" \
 "Successfully configured GitHub Actions!"

# Configure PR template
print_info_message "Configuring GitHub PR template..."
touch ./.github/pull_request_template.md
cat <<PR_TEMPLATE >./.github/pull_request_template.md
### Added

- [Added ...]

### Changed

- [Changed ...]

### Removed

- [Removed ...]

### Fixed

- [Fixed ...]

---

PR_TEMPLATE
check_errors "Could not configure GitHub PR template!" \
 "Successfully configured GitHub PR template!"

# Configure README.md
print_info_message "Configuring README..."
touch README.md
cat <<README >README.md
# stoplight-docs-$NAME

This is the repository behind https://publiq.stoplight.io/docs/$NAME

## Contribution

1. Create a branch with your changes
2. Create a PR for your branch
3. Fix any problems detected by the automatic checks
4. Merge once someone has reviewed and approved your changes

Be sure to also check the [internal guidelines](https://publiq.stoplight.io/docs/guidelines) on how to design APIs and write documentation. **(Login required)**

> ### Warning!
>
> Never update the following files manually, but use [cultuurnet/stoplight-ci](https://github.com/cultuurnet/stoplight-ci) instead!
>
> If you update them manually, your changes will get overwritten in later updates to the CI setup.
>
> - \`README.md\`
> - \`.spectral.json\`
> - \`.remarkrc\`
> - \`.github/pull_request_template.md\`
> - \`.github/workflows/ci.yml\`

## Automatic checks

The automatic checks will be run via GitHub actions for every commit pushed to every branch.

Some examples of automatic checks are dead links in the docs, malformed Markdown in the docs, or invalid JSON in the OpenAPI file(s).

To run them locally, you'll need [node](https://nodejs.org/en/) and [yarn](https://yarnpkg.com/getting-started/install).

### Installing the required packages

To install or update the required packages to run the checks, run \`yarn install\`.

### Checking the Markdown files for errors

Run \`yarn docs:lint\` to check for errors or warnings. If any errors or warnings are detected, you can either fix them manually or try to fix them with \`yarn docs:lint:fix\`

### Checking the OpenAPI files for errors

Run \`yarn api:lint\` to check for errors or warnings. If any errors or warnings are detected, you need to fix them manually for now.

README
check_errors "Could not configure README!" \
 "Successfully configured README!"
