#!/usr/bin/env bash

#######################################
# Build Docker image.
# Globals:
#   docker
# Arguments:
#   [1] $__docker_image_tag     Docker Image Tag.
#   [2] $__docker_context_path  Path to Docker Context (files getting copied to Docker image).
#   [3] $__docker_config_file   [optional] Path to Dockerfile. Default looks for 'Dockerfile' in Context path.
#   [*]                         All additional args are passed to the 'docker build' command.
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
  __docker_opts=()
  # Do not use cache when building the image.
  # __docker_opts+=(--no-cache)
  # Remove intermediate containers after a successful build.
  __docker_opts+=(--rm)
  # Name of the Dockerfile (Default is 'PATH/Dockerfile').
  __docker_opts+=(-f "${__docker_config_file:-$__docker_context_path/Dockerfile}")
  # Name and optionally a tag in the 'name:tag' format.
  __docker_opts+=(-t "$__docker_image_tag")

  # Start timer to measure/report on docker build time.
  __start_time="$(date +%s)"

  docker build "${__docker_opts[@]}" "$@" "$__docker_context_path"

  __end_time="$(date +%s)"
  __runlen="$(echo "$__end_time - ${__start_time}" | bc)"
  __runtime="$__runlen seconds"
  if type "python" &> /dev/null; then
    __runtime="$(python -c "print '%u:%02u' % ($__runlen/60, $__runlen%60)")"
  fi
  echo -e "\n$(date +%Y-%m-%dT%H:%M:%S%z) [INFO] Docker image ($__docker_image_tag) build took ${__runtime}.\n"

  # shellcheck disable=SC2046
  docker rmi -f $(docker images -f "dangling=true" -q) 2> /dev/null
  docker images
}

#######################################
# Remove Docker image.
# Globals:
#   docker
# Arguments:
#   [1] $__docker_image_tag   Docker Image Tag.
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
#   [1] $__docker_image_tag     Docker Image Tag.
#   [2] $__docker_context_path  Path to Docker Context (files getting copied to Docker image).
#   [3] $__docker_config_file   [optional] Path to Dockerfile. Default looks for 'Dockerfile' in Context path.
#   [*]                         All additional args are passed to the container entrypoint script.
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
  __docker_config_file="${1:-$__docker_context_path/Dockerfile}" && shift
  __docker_config_dir_path="${__docker_config_file%\/Dockerfile*}"

  # shellcheck disable=SC2086
  if [[ "$(docker images $__docker_image_tag -q)" = "" ]]; then
    build_docker_image "$__docker_image_tag" "$__docker_context_path" "$__docker_config_file" || {
      echo $?
      exit 1
    }
  fi
  # Set options for 'docker run' command.
  __docker_opts=()
  # Interactive (Keep STDIN open even if not attached).
  __docker_opts+=(-i)
  # Allocate a pseudo-TTY.
  __docker_opts+=(-t)
  # Automatically remove the container when it exits.
  __docker_opts+=(--rm)
  # Pass environment variables.
  __env_vars=(
    "TZ=${TZ:-}"
    "AWS_ADFS_HOST=${AWS_ADFS_HOST:-}"
    "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}"
    "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}"
    "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}"
    "GITHUB_TOKEN=${GH_TOKEN:-}"
    "GH_TOKEN=${GH_TOKEN:-}"
    "NPM_TOKEN=${NPM_TOKEN:-}"
  )
  for _val in "${__env_vars[@]}"; do __docker_opts+=(-e "$_val"); done
  unset _val

  if [[ -r "$__docker_config_dir_path/.env" ]] && [[ -f "$__docker_config_dir_path/.env" ]]; then
    __docker_opts+=(--env-file "$__docker_config_dir_path/.env")
  fi

  # Mount volume to map current directory (on host) to work directory (on container).
  __docker_opts+=(-v "$__pwd_path:$__image_work_path")
  # Mount volume for dotfiles to keep them synced.
  __docker_opts+=(-v "$__docker_context_path/dotfiles:$__image_home_path/dotfiles")

  # Mount volumes for read-only credentials/config:
  __user_conf_read_only=(
    ".gemrc"            # Use host Ruby-gem runtime configuration (read-only).
    ".gitattributes"    # Use host global Git settings (read-only).
    ".gitconfig"        # Use host Git config/credentials (read-only).
    ".gitignore"        # Use host global Git-ignore settings (read-only).
    ".localrc"          # Use host local runtime configuration (read-only).
    ".mongorc.js"       # Use host MongoDB runtime configuration (read-only).
    ".npmrc"            # Use host npm runtime configuration (read-only).
    ".serverlessrc"     # Use host Serverless runtime configuration (read-only).
    ".ssh"              # Use host SSH keys (read-only).
    ".subversion"       # Use host Subversion configuration (read-only).
  )
  for _val in "${__user_conf_read_only[@]}"; do
    if [[ -e "$__host_home_path/$_val" ]]; then
      __docker_opts+=(-v "$__host_home_path/$_val:$__image_home_path/$_val:ro")
    fi
  done
  unset _val

  # Mount volumes for persistence:
  __user_conf_write=(
    ".aws"              # Allow AWS-CLI config/prefs to be synced on host.
    ".serverless"       # Allow Serverless config/prefs to be synced on host.
    ".sonarlint"        # Allow Sonar Lint config/prefs to be synced on host.
    ".terraform.d"      # Allow Terraform config/prefs to be synced on host.
    ".travis"           # Allow Travis CLI config/prefs to be synced on host.
  )
  for _val in "${__user_conf_write[@]}"; do
    if [[ -e "$__host_home_path/$_val" ]]; then
      __docker_opts+=(-v "$__host_home_path/$_val:$__image_home_path/$_val")
    fi
  done
  unset _val

  # Make container name from image name and append datetime for uniqueness.
  __docker_container_name="${__docker_image_tag%:*}"
  __docker_container_name="${__docker_container_name#*\/}_$(date +%m%d%H%M)"
  __docker_opts+=(--name "$__docker_container_name")
  __docker_opts+=(--hostname "$__docker_container_name")

  # Finally, run docker container.
  docker run "${__docker_opts[@]}" "$__docker_image_tag" "$@"
}
