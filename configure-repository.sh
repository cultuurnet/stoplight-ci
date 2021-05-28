#!/bin/bash

# Shell script that clones a given git repository, switches to a new branch,
# runs the configure-ci.sh script on it, and pushes the branch.
# Arguments:
# - Repository url (https or ssh, depending on what you normally use)
# - Branch name to commit and push the changes on

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

# Check if at least one argument is specified
if [ $# -lt 2 ]
then
   print_error_message "Please provide 2 arguments: The URL of the repository, and the branch name to commit changes to."
   cd $1
fi

URL=$1
BRANCH=$2

REPO_NAME=$(basename $URL)
PROJECT_NAME=${REPO_NAME%.*}

# Check that git is available
if ! check_command_exists "git"; then
  print_error_message "Git not found. Please install it first https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
fi

# Clone the repository
print_info_message "Cloning $URL..."
rm -rf ./$PROJECT_NAME
git clone $URL ./$PROJECT_NAME
check_errors "Failed to clone $URL" \
 "Successfully cloned $URL"

print_info_message "Switching active directory to $PROJECT_NAME..."
cd $PROJECT_NAME
check_errors "Failed to switch active directory to $PROJECT_NAME" \
 "Successfully switched active directory to $PROJECT_NAME"

print_info_message "Switching to branch $BRANCH..."
git checkout -t origin/$BRANCH
if [ ! $? -eq 0 ]; then
  print_info_message "Creating new branch $BRANCH..."
  git switch -c $BRANCH
fi
check_errors "Failed to switch to branch $BRANCH" \
 "Successfully switched to branch $BRANCH"

print_info_message "Running configure-ci.sh script..."
./../configure-ci.sh $PWD
check_errors "Failed to run configure-ci.sh script" \
 "Successfully ran configure-ci.sh script"

print_info_message "Checking for changes..."
CHANGES=1
if [[ ! `git status --porcelain` ]]; then
  print_success_message "No changes found after running configure-ci.sh. Nothing to commit or push."
  CHANGES=0
fi

if [ $CHANGES == 1 ]; then
  print_info_message "Staging changes..."
  git add -A
  check_errors "Failed to stage changes" \
   "Successfully staged changes"

  print_info_message "Committing changes..."
  git commit -m "Configure/update CI scripts and templates"
  check_errors "Failed to commit changes" \
   "Successfully committed changes"

  print_info_message "Pushing changes..."
  git push --set-upstream origin $BRANCH
  check_errors "Failed to push changes" \
   "Successfully pushed changes"
fi

print_info_message "Switching back to original directory..."
cd -
check_errors "Failed to switch back to original directory" \
 "Successfully switched back to original directory"

print_info_message "Removing local clone..."
rm -rf ./$PROJECT_NAME
check_errors "Failed to remove local clone" \
 "Successfully removed local clone"

if [ $CHANGES == 1 ]; then
  print_success_message "Successfully updated CI config of $URL! Don't forget to open a PR with the changes."
fi
