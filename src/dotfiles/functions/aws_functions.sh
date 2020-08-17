#!/usr/bin/env bash
# shellcheck disable=SC2139

alias awslist="aws-adfs list"
alias awsreset="aws-adfs reset"
alias awsid="aws sts get-caller-identity"

awslogout () {
  echo -e "[INFO] [awslogout] Clearing existing sessions and default profile."
  echo -e "[DEBUG] [awslogout] AWS_DEFAULT_PROFILE = ${AWS_DEFAULT_PROFILE:-}\n[DEBUG] AWS_PROFILE = ${AWS_PROFILE:-}"
  aws-adfs reset
  AWS_PROFILE=""
  echo -e "[DEBUG] [awslogout] AWS_PROFILE = ${AWS_PROFILE:-}"
}

awslogin () {
  awslogout
  echo
  _profile_name="${1:-}"
  [[ -z "${_profile_name}" ]] && {
    aws-adfs list
    echo
    read -r -p "[???] Please provide an AWS Named Profile to use: " _profile_name
    [[ -z "${_profile_name}" ]] && {
      echo -e "[ERROR] [awslogin] Please provide an AWS Named Profile to use.\n"
      exit 1
    }
  }
  export AWS_PROFILE="${_profile_name}"
  echo -e "[DEBUG] [awslogin] AWS_DEFAULT_PROFILE = ${AWS_DEFAULT_PROFILE:-}\n[DEBUG] AWS_PROFILE = ${AWS_PROFILE:-}"
  echo
  echo -e "[INFO] [awslogin] Running 'aws-adfs login'."
  echo -e "[NOTE] [awslogin] Please select the Account and Role matching the Profile you selected (${_profile_name})."
  aws-adfs login --adfs-host="${AWS_ADFS_HOST:-}" --provider-id urn:amazon:webservices --no-sspi
  echo
  echo -e "[INFO] [awslogin] Setting AWS_PROFILE=default to ensure AWS-CLI uses the ADFS-generated 'default' Profile."
  export AWS_PROFILE="default"
  echo -e "[DEBUG] [awslogin] AWS_DEFAULT_PROFILE = ${AWS_DEFAULT_PROFILE:-}\n[DEBUG] [awslogin] AWS_PROFILE = ${AWS_PROFILE:-}"
  echo
  echo -e "[INFO] [awslogin] Running 'aws sts get-caller-identity' to verify session identity."
  aws sts get-caller-identity
}
