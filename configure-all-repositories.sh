#!/bin/bash

# Shell script that loops over every known stoplight-docs repository and runs configure-repository.sh for it.
# Will ask for confirmation first.
# Arguments:
# - Branch name to commit and push the changes on

declare -a REPOSITORIES=(
  "git@github.com:cultuurnet/stoplight-docs-authentication.git"
  "git@github.com:cultuurnet/stoplight-docs-guidelines.git"
  "git@github.com:cultuurnet/stoplight-docs-uitdatabank.git"
  "git@github.com:cultuurnet/stoplight-docs-uitpas.git"
)

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

# Check if at least one argument is specified
if [ $# -lt 1 ]
then
   print_error_message "Please provide 1 argument: The branch name to commit changes to."
   exit 1
fi

BRANCH=$1

LENGTH=${#REPOSITORIES[@]}
print_info_message "This will configure the following ${LENGTH} repositories:"

for (( i=0; i<$LENGTH; i++ )); do
  NUMBER=$(($i+1))
  echo "  $NUMBER. ${REPOSITORIES[$i]}";
done

read -p " Are you sure? [y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    print_error_message "Aborted configuration of repositories."
    exit 1
fi

for (( i=0; i<$LENGTH; i++ )); do
  REPOSITORY=${REPOSITORIES[$i]}
  print_info_message "Configuring $REPOSITORY..."

  ./configure-repository.sh $REPOSITORY $BRANCH

  check_errors "Failed to configure $REPOSITORY" \
    "Successfully configured $REPOSITORY"
done

print_success_message "Updated configuration of ${LENGTH} repositories."
print_info_message "Don't forget to create PRs for your changes!"



