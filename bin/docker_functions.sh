#!/usr/bin/env bash

__runbox_repo_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#######################################
# Build Docker image.
# Globals:
#   docker
# Arguments:
#   None
# Returns:
#   None
#######################################
build_docker_image () {
  local \
    __docker_image_tag \
    __docker_context_path \
    __docker_config_file \
    ;
  __docker_image_tag="${1:-this/box:latest}" && shift
  __docker_context_path="${1:-./}" && shift
  __docker_config_file="${1:-}" && shift

  docker rmi -f "$__docker_image_tag" 2> /dev/null
  # Set options for 'docker build' command.
  _docker_opts=()
  # Do not use cache when building the image.
  # _docker_opts+=(--no-cache)
  # Remove intermediate containers after a successful build.
  _docker_opts+=(--rm)
  # Name of the Dockerfile (Default is 'PATH/Dockerfile').
  _docker_opts+=(-f "${__docker_config_file:-$__docker_context_path/Dockerfile}")
  # Name and optionally a tag in the 'name:tag' format.
  _docker_opts+=(-t "$__docker_image_tag")

  # Start timer to measure/report on docker build time.
  _start_time="$(date +%s)"

  docker build "${_docker_opts[@]}" "$@" "$__docker_context_path"

  _end_time="$(date +%s)"
  _runlen="$(echo "$_end_time - ${_start_time}" | bc)"
  _runtime="$_runlen seconds"
  if type "python" &> /dev/null; then
    _runtime="$(python -c "print '%u:%02u' % ($_runlen/60, $_runlen%60)")"
  fi
  echo -e "\n$(date +%Y-%m-%dT%H:%M:%S%z) [INFO] Docker image ($__docker_image_tag) build took ${_runtime}.\n"

  # shellcheck disable=SC2046
  docker rmi -f $(docker images -f "dangling=true" -q) 2> /dev/null
  docker images
}

#######################################
# Remove Docker image.
# Globals:
#   docker
# Arguments:
#   None
# Returns:
#   None
#######################################
remove_docker_image () {
  docker rmi -f "${1:-}" 2> /dev/null
  # shellcheck disable=SC2046
  docker rmi -f $(docker images -f "dangling=true" -q) 2> /dev/null
  docker images
}

#######################################
# Run Docker container.
# Globals:
#   docker
# Arguments:
#   Passes arguments to the 'docker run' command.
# Returns:
#   None
# Example:
#   run_docker_container "image/tag:latest" "path/to/docker/context" "path/to/Dockerfile" ...
#######################################
run_docker_container () {
  # Declare/set variables.
  local \
    __docker_image_tag \
    __docker_context_path \
    __docker_config_file \
    __pwd_path \
    __host_home_path="${HOME:-~}" \
    __image_home_path="/home/${USER_NAME:-dev}" \
    __image_work_path="/mnt/pwd" \
    ;
  __pwd_path="$(pwd)"
  __docker_image_tag="${1:-this/box:latest}" && shift
  __docker_context_path="${1:-./}" && shift
  __docker_config_file="${1:-}" && shift

  # shellcheck disable=SC2086
  if [[ "$(docker images $__docker_image_tag -q)" = "" ]]; then
    build_docker_image "$__docker_image_tag" "$__docker_context_path" "$__docker_config_file" || {
      echo $?
      exit 1
    }
  fi
  # Set options for 'docker run' command.
  _docker_opts=()
  # Interactive (Keep STDIN open even if not attached).
  _docker_opts+=(-i)
  # Allocate a pseudo-TTY.
  _docker_opts+=(-t)
  # Automatically remove the container when it exits.
  _docker_opts+=(--rm)
  # Pass environment variables.
  _docker_opts+=(-e "TZ=${TZ:-}")
  _docker_opts+=(-e "AWS_ADFS_HOST=${AWS_ADFS_HOST:-}")
  _docker_opts+=(-e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}")
  _docker_opts+=(-e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}")
  _docker_opts+=(-e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}")
  _docker_opts+=(-e "GITHUB_TOKEN=${GH_TOKEN:-}")
  _docker_opts+=(-e "GH_TOKEN=${GH_TOKEN:-}")
  _docker_opts+=(-e "NPM_TOKEN=${NPM_TOKEN:-}")
  if [[ -r "$__runbox_repo_path/.env" ]] && [[ -f "$__runbox_repo_path/.env" ]]; then
    _docker_opts+=(--env-file "$__runbox_repo_path/.env")
  fi
  # if [[ -r "$__pwd_path/.env" ]] && [[ -f "$__pwd_path/.env" ]]; then
  #   _docker_opts+=(--env-file "$__pwd_path/.env")
  # fi
  # Mount volume to map current directory (on host) to work directory (on container).
  _docker_opts+=(-v "$__pwd_path:$__image_work_path")
  # Mount volume for dotfiles to keep them synced.
  _docker_opts+=(-v "$__docker_context_path/dotfiles:$__image_home_path/dotfiles")
  # Mount volumes for read-only credentials/config:
  # Use host user's SSH keys (read-only).
  if [[ -e "$__host_home_path/.ssh" ]]; then
    _docker_opts+=(-v "$__host_home_path/.ssh:$__image_home_path/.ssh:ro")
  fi
  # Use host user's Git config/credentials (read-only).
  if [[ -e "$__host_home_path/.gitconfig" ]]; then
    _docker_opts+=(-v "$__host_home_path/.gitconfig:$__image_home_path/.gitconfig:ro")
  fi
  if [[ -e "$__host_home_path/.gitattributes" ]]; then
    _docker_opts+=(-v "$__host_home_path/.gitattributes:$__image_home_path/.gitattributes:ro")
  fi
  if [[ -e "$__host_home_path/.gitignore" ]]; then
    _docker_opts+=(-v "$__host_home_path/.gitignore:$__image_home_path/.gitignore:ro")
  fi
  # Use host user's Subversion configuration (read-only).
  if [[ -e "$__host_home_path/.subversion" ]]; then
    _docker_opts+=(-v "$__host_home_path/.subversion:$__image_home_path/.subversion:ro")
  fi
  # Use host user's local runtime configuration (read-only).
  if [[ -e "$__host_home_path/.localrc" ]]; then
    _docker_opts+=(-v "$__host_home_path/.localrc:$__image_home_path/.localrc:ro")
  fi
  # Use host user's npm runtime configuration (read-only).
  if [[ -e "$__host_home_path/.npmrc" ]]; then
    _docker_opts+=(-v "$__host_home_path/.npmrc:$__image_home_path/.npmrc:ro")
  fi
  # Use host user's gem runtime configuration (read-only).
  if [[ -e "$__host_home_path/.gemrc" ]]; then
    _docker_opts+=(-v "$__host_home_path/.gemrc:$__image_home_path/.gemrc:ro")
  fi
  # Use host user's Serverless runtime configuration (read-only).
  if [[ -e "$__host_home_path/.serverlessrc" ]]; then
    _docker_opts+=(-v "$__host_home_path/.serverlessrc:$__image_home_path/.serverlessrc:ro")
  fi
  # Use host user's MongoDB runtime configuration (read-only).
  if [[ -e "$__host_home_path/.mongorc.js" ]]; then
    _docker_opts+=(-v "$__host_home_path/.mongorc.js:$__image_home_path/.mongorc.js:ro")
  fi
  # Mount volumes for persistence:
  # Allow Serverless config/prefs to be synced on host.
  if [[ -e "$__host_home_path/.serverless" ]]; then
    _docker_opts+=(-v "$__host_home_path/.serverless:$__image_home_path/.serverless")
  fi
  # Allow Travis CLI config/prefs to be synced on host.
  _docker_opts+=(-v "$__host_home_path/.travis:$__image_home_path/.travis")
  # Allow Sonar Lint config/prefs to be synced on host.
  _docker_opts+=(-v "$__host_home_path/.sonarlint:$__image_home_path/.sonarlint")
  # Allow AWS-CLI config/prefs to be synced on host.
  _docker_opts+=(-v "$__host_home_path/.aws:$__image_home_path/.aws")
  # Allow Terraform config/prefs to be synced on host.
  _docker_opts+=(-v "$__host_home_path/.terraform.d:$__image_home_path/.terraform.d")

  # Container name.
  # _docker_opts+=(--name "$__name")

  docker run "${_docker_opts[@]}" "$__docker_image_tag" "$@"
}
