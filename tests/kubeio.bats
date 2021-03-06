#!/usr/bin/env bats

__from="minikube"

__namespace="default"

__resource="all"

__output="json"

__kcov="kcov --exclude-path=coverage/,tests/,.travis.yml,.git/,~/bin,$BATS_TEST_DIRNAME/../install.sh coverage"

__mask_args="get %s -o %s -n %s"

__args=$(printf "$__mask_args" "$__resource" "$__output" "$__namespace")

__command="$BATS_TEST_DIRNAME/../kubeio"

__file="$BATS_TEST_DIRNAME/../$__resource.$__output"

__command_short="$__command -f $__from -n $__namespace -r $__resource \
    -o $__output"

__command_full="$__command --from $__from --namespace $__namespace \
    --resource $__resource --output $__output"

__current_context="xpto0"

__last_command=""

setup() {
  . $BATS_TEST_DIRNAME/shellmock
  shellmock_clean
  shellmock_expect kubectl
}

teardown()
{
  if [ -z "$BATS_TEST_SKIPPED" ] && [ "$BATS_TEST_COMPLETED" -eq 1 ] && [ ! -z "$__last_command" ] ; then
    $__kcov $__last_command
  fi

  shellmock_clean
  rm -f $__file
}

@test "kubectl is not installed short" {
  shellmock_clean
  shellmock_expect kubectl --status 127

  __last_command=$__command_short

  run ${__last_command}

  [ "$status" -eq 127 ]
  [ "$output" = "kubectl is not installed" ]
}

@test "kubectl is not installed full" {
  shellmock_clean
  shellmock_expect kubectl --status 127

  __last_command=$__command_full

  run ${__last_command}

  [ "$status" -eq 127 ]
  [ "$output" = "kubectl is not installed" ]
}

@test "kubeio without arguments" {
  __last_command=$__command

  run ${__last_command}

  [ "$status" -eq 1 ]
}

@test "kubeio -h" {
  __last_command="$__command -h"

  run ${__last_command}

  [ "$status" -eq 0 ]
}

@test "kubeio --help" {
  __last_command="$__command --help"

  run ${__last_command}

  [ "$status" -eq 0 ]
}

@test "kubeio with -f success" {
  local context="xpto1"

  __kubeio_success_with_param_f_or_from "$__command -f %s" $context
}

@test "kubeio with --from success" {
  local context="xpto1"

  __kubeio_success_with_param_f_or_from "$__command --from %s" $context
}

function __kubeio_success_with_param_f_or_from () {
  local context="${2}"
  __last_command=$(printf "${1} ""$context")

  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $context"

  shellmock_expect kubectl --status 0 --match "$__args" --output "xpto2"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect kubectl --status 0 --match "apply -f -"

  run ${__last_command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$__resource' applied with successfully" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $context" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with -f fail get context" {
  local context="xpto1"

  __kubeio_unsuccess_with_param_f_or_from "$__command -f" $context
}

@test "kubeio with --from fail get context" {
  local context="xpto1"

  __kubeio_unsuccess_with_param_f_or_from "$__command --from" $context
}

function __kubeio_unsuccess_with_param_f_or_from () {
  local context="${2}"

  shellmock_expect kubectl --status 1 --match "config current-context" --output "xpto2"

  __last_command="${1} "$context

  run ${__last_command}

  [ "$status" -eq 1 ]
  [ "$output" = "xpto2" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
}

@test "kubeio with -f fail same context" {
  local context="xpto1"

  __kubeio_unsuccess_with_param_f_or_from_equal_current_context "$__command -f" $context
}

@test "kubeio with --from fail same context" {
  local context="xpto1"

  __kubeio_unsuccess_with_param_f_or_from_equal_current_context "$__command --from" $context
}

function __kubeio_unsuccess_with_param_f_or_from_equal_current_context () {
  local context="${2}"

  shellmock_expect kubectl --status 0 --match "config current-context" --output "$context"

  __last_command="${1} "$context

  run ${__last_command}

  [ "$status" -eq 1 ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
}

@test "kubeio with short options kubectl get fail" {
  __kubeio_kubecelt_get_fail "$__command_short"
}

@test "kubeio with full options kubectl get fail" {
  __kubeio_kubecelt_get_fail "$__command_full"
}

function __kubeio_kubecelt_get_fail() {
  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 2 --match "$__args" --output "Any Error"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  __last_command="${1}"

  run ${__last_command}

  [ "$status" -eq 2 ]
  [ "$output" = "Any Error" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with short options kubectl get success" {
  __kubeio_success_all_short_or_full_options "$__command_short"
}

@test "kubeio with full options kubectl get success" {
  __kubeio_success_all_short_or_full_options "$__command_full"
}

function __kubeio_success_all_short_or_full_options() {
  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect kubectl --status 0 --match "apply -f -"

  __last_command="${1}"

  run ${__last_command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$__resource' applied with successfully" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio only the -n parameter" {
  __last_command="$__command -n"

  run ${__last_command}

  [ "$status" -eq 0 ]
}

@test "kubeio only the --namespace parameter" {
  __last_command="$__command --namespace"

  run ${__last_command}

  [ "$status" -eq 1 ]
}

@test "kubeio only the -o parameter" {
  __last_command="$__command -o"

  run ${__last_command}

  [ "$status" -eq 0 ]
}

@test "kubeio only the --output parameter" {
  __last_command="$__command --output"

  run ${__last_command}

  [ "$status" -eq 1 ]
}

@test "kubeio with full options apply fail" {
  __kubeio_unsuccess_with_short_or_full_params_apply_fail "$__command_full"
}

@test "kubeio with short options apply fail" {
  __kubeio_unsuccess_with_short_or_full_params_apply_fail "$__command_short"
}

function __kubeio_unsuccess_with_short_or_full_params_apply_fail () {
  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect kubectl --status 1 --match "apply -f -" --output "fail"

  __last_command="${1}"

  run ${__last_command}

  [ "$status" -eq 1 ]
  [ "$output" = "fail" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}


@test "kubeio with -f unsuccess touch fail" {
  local context="xpto1"

  __kubeio_unsuccess_with_f_or_from_params_apply_fail "$__command -f %s" $context
}

@test "kubeio with --from unsuccess touch fail" {
  local context="xpto1"

  __kubeio_unsuccess_with_f_or_from_params_apply_fail "$__command --from %s" $context
}

function __kubeio_unsuccess_with_f_or_from_params_apply_fail () {
  local context="${2}"
  __last_command=$(printf "${1}" "$context")

  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $context"

  shellmock_expect kubectl --status 0 --match "$__args" --output "xpto2"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect kubectl --status 1 --match "apply -f -" --output "fail"

  run ${__last_command}

  [ "$status" -eq 1 ]
  [ "$output" = "fail" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $context" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with -f and -r success" {
  local context="xpto1"
  local resource="deployments/xpto-1"

  __kubeio_success_with_param_f_or_from_and_r_or_resource "$__command -f %s -r %s" $context $resource
}

@test "kubeio with --from and --resource success" {
  local context="xpto1"
  local resource="deployments/xpto-1"

  __kubeio_success_with_param_f_or_from_and_r_or_resource "$__command --from %s --resource %s" $context $resource
}

function __kubeio_success_with_param_f_or_from_and_r_or_resource () {
  local context="${2}"
  local resource="${3}"
  local args=$(printf "$__mask_args" "$resource" "$__output" "$__namespace")
  __last_command=$(printf "${1}" "$context" "$resource")

  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $context"

  shellmock_expect kubectl --status 0 --match "$args" --output "xpto2"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect kubectl --status 0 --match "apply -f -"

  run ${__last_command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$resource' applied with successfully" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $context" ]
  [ "${capture[3]}" = "kubectl-stub $args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with short options and -d success" {
  __kubeio_success_all_short_or_full_more_d_or_download_options "$__command_short -d"
}

@test "kubeio with full options and --download success" {
  __kubeio_success_all_short_or_full_more_d_or_download_options "$__command_full --download"
}

function __kubeio_success_all_short_or_full_more_d_or_download_options() {
  local file
  file=$(echo $__resource.$__output | sed -e "s/\(.*\)\/\(.*\)/\1_\2/" 2>&1)

  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect kubectl --status 0 --match "apply -f -"

  __last_command="${1}"

  run ${__last_command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$file' file saved successfully" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with short options and -d unsuccess" {
  __kubeio_success_all_short_or_full_more_a_or_apply_apply_fail "$__command_short -d"
}

@test "kubeio with full options and --download unsuccess" {
  __kubeio_success_all_short_or_full_more_a_or_apply_apply_fail "$__command_full --download"
}

function __kubeio_success_all_short_or_full_more_a_or_apply_apply_fail () {
  shellmock_expect kubectl --status 0 --match "config current-context" --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  shellmock_expect kubectl --status 0 --match "config use-context $__current_context"

  shellmock_expect touch --status 1 --match "$__resource.$__output" --output "fail"

  __last_command="${1}"

  run ${__last_command}

  [ "$status" -eq 1 ]
  [ "$output" = "fail" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}


#  local file=$(echo $__resource.$__output | sed -e "s/\(.*\)\/\(.*\)/\1_\2/" 2>&1)
# local content=$(cat "$file")
# [ "$content" = "Success" ]
