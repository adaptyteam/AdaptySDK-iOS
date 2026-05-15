#!/usr/bin/env bash

# Any helper responsible for an uploaded artifact log must initialize shared
# logging before its first failing command.

ci_format_command() {
  if [[ $# -eq 0 ]]; then
    printf '<empty>\n'
    return 0
  fi

  local arg
  printf '%q' "$1"
  shift

  for arg in "$@"; do
    printf ' %q' "$arg"
  done

  printf '\n'
}

ci_init_artifact_log() {
  if [[ $# -lt 2 ]]; then
    echo "Error: ci_init_artifact_log requires <script_name> <log_path> [args...]." >&2
    return 1
  fi

  local script_name="$1"
  shift

  local log_path="$1"
  shift

  local log_dir
  log_dir="$(dirname "$log_path")"

  if ! mkdir -p "$log_dir"; then
    echo "Error: Failed to create log directory '$log_dir'." >&2
    return 1
  fi

  if ! : > "$log_path"; then
    echo "Error: Failed to initialize log file '$log_path'." >&2
    return 1
  fi

  if ! exec > >(tee -a "$log_path") 2>&1; then
    local message
    message="Error: Failed to mirror output into '$log_path'."
    printf '%s\n' "$message" >> "$log_path" 2>/dev/null || true
    echo "$message" >&2
    return 1
  fi

  local timestamp
  timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  echo "=== ${script_name} started at ${timestamp} ==="
  echo "=== Working directory: $(pwd) ==="
  echo "=== Log file: ${log_path} ==="

  if [[ $# -gt 0 ]]; then
    local argument
    printf '=== Arguments:'
    for argument in "$@"; do
      printf ' %q' "$argument"
    done
    printf '\n'
  fi
}

ci_log_section() {
  if [[ $# -lt 1 ]]; then
    echo "Error: ci_log_section requires a title." >&2
    return 1
  fi

  echo "=== $* ==="
}

ci_run_logged_command() {
  if [[ $# -eq 0 ]]; then
    echo "Error: ci_run_logged_command requires a command." >&2
    return 1
  fi

  ci_log_section "Running command"
  printf '+ '
  ci_format_command "$@"

  local had_errexit=0
  case $- in
    *e*) had_errexit=1 ;;
  esac

  set +e
  "$@"
  local command_exit_code=$?
  if [[ $had_errexit -eq 1 ]]; then
    set -e
  fi

  echo "=== Command exit code: ${command_exit_code} ==="
  return "$command_exit_code"
}

ci_run_logged_command_capture_exit() {
  if [[ $# -lt 2 ]]; then
    echo "Error: ci_run_logged_command_capture_exit requires <result_var> <command...>." >&2
    return 1
  fi

  local result_var="$1"
  shift

  ci_log_section "Running command"
  printf '+ '
  ci_format_command "$@"

  local had_errexit=0
  case $- in
    *e*) had_errexit=1 ;;
  esac

  set +e
  "$@"
  local command_exit_code=$?
  if [[ $had_errexit -eq 1 ]]; then
    set -e
  fi

  echo "=== Command exit code: ${command_exit_code} ==="
  printf -v "$result_var" '%s' "$command_exit_code"
}
