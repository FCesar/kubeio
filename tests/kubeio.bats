#!/usr/bin/env bats

__from="minikube"

__namespace="default"

__resource="all"

__output="json"

__args="get $__resource -o $__output -n $__namespace"

__command="$BATS_TEST_DIRNAME/../kubeio"

__file="$BATS_TEST_DIRNAME/../$__resource.$__output"

__command_short="$__command -f $__from -n $__namespace -r $__resource \
    -o $__output"

__command_full="$__command --from $__from --namespace $__namespace \
    --resource $__resource --output $__output"

__current_context="xpto0"

#kubectl get $__resource -o $__output

setup() {
  . shellmock
  shellmock_clean
}

teardown()
{
  if [ -z "$TEST_FUNCTION" ];then
     shellmock_clean
  fi
  rm -f $__file
}

@test "kubectl is not installed short" {
  shellmock_expect kubectl --status 127

  run ${__command_short}

  [ "$status" -eq 127 ]
  [ "$output" = "kubectl is not installed" ]
}

@test "kubectl is not installed full" {
  shellmock_expect kubectl --status 127

  run ${__command_full}

  [ "$status" -eq 127 ]
  [ "$output" = "kubectl is not installed" ]
}

@test "kubeio without arguments" {
  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeio -h" {
  local command="$__command -h"

  run ${command}

  [ "$status" -eq 0 ]
}

@test "kubeio --help" {
  local command="$__command --help"

  run ${command}

  [ "$status" -eq 0 ]
}

@test "kubeio with -f success" {
  local context="xpto1"

  __success_with_param_f_or_from "$__command -f" $context
}

@test "kubeio with --from success" {
  local context="xpto1"

  __success_with_param_f_or_from "$__command --from" $context
}

function __success_with_param_f_or_from () {
  local context="${2}"

  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $context"

  shellmock_expect kubectl --status 0 --match "$__args" --output "xpto2"

  shellmock_expect kubectl --status 0 --match "config use-context " \
    "$__current_context"

  local command="${1} "$context

  run ${command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$__resource.$__output' file saved successfully" ]

  local content=$(cat "$__file")
  [ "$content" = "xpto2" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $context" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with -f fail get context" {
  local context="xpto1"

  __unsuccess_with_param_f_or_from "$__command -f" $context
}

@test "kubeio with --from fail get context" {
  local context="xpto1"

  __unsuccess_with_param_f_or_from "$__command --from" $context
}

function __unsuccess_with_param_f_or_from () {
  local context="${2}"

  shellmock_expect kubectl --status 1 --match "config current-context" \
    --output "xpto2"

  local command="${1} "$context

  run ${command}

  [ "$status" -eq 1 ]
  [ "$output" = "xpto2" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
}

@test "kubeio with -f fail same context" {
  local context="xpto1"

  __unsuccess_with_param_f_or_from_equal_current_context "$__command -f" \
    $context
}

@test "kubeio with --from fail same context" {
  local context="xpto1"

  __unsuccess_with_param_f_or_from_equal_current_context "$__command --from" \
    $context
}

function __unsuccess_with_param_f_or_from_equal_current_context () {
  local context="${2}"

  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$context"

  local command="${1} "$context

  run ${command}

  [ "$status" -eq 1 ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
}

@test "kubeio with short options kubectl get fail" {
  __kubeio_kubecelt_get_fail "${__command_short}"
}

@test "kubeio with full options kubectl get fail" {
  __kubeio_kubecelt_get_fail "${__command_full}"
}

function __kubeio_kubecelt_get_fail() {
  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 2 --match "$__args" --output "Any Error"

  shellmock_expect kubectl --status 0 --match "config use-context " \
    "$__current_context"

  run ${1}

  [ "$status" -eq 2 ]
  [ "$output" = "Any Error" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio with short options kubectl get success" {
  __kubeio_success_all_short_options "${__command_short}"
}

@test "kubeio with flul options kubectl get success" {
  __kubeio_success_all_short_options "${__command_full}"
}

function __kubeio_success_all_short_options() {
  local command="${1}"

  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  shellmock_expect kubectl --status 0 --match "config use-context " \
    "$__current_context"

  run ${command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$__resource.$__output' file saved successfully" ]

  local content=$(cat "$__file")
  [ "$content" = "Success" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $__from" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}

@test "kubeio only the -n parameter" {
  local command="$__command -n"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeio only the --namespace parameter" {
  local command="$__command --namespace"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeio only the -o parameter" {
  local command="$__command -o"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeio only the --output parameter" {
  local command="$__command --output"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeio with full options touch fail" {
  __kubeio_unsuccess_touch_fail "${__command_full}"
}

@test "kubeio with short options touch fail" {
  __kubeio_unsuccess_touch_fail "${__command_short}"
}

function __kubeio_unsuccess_touch_fail() {
  local command="${1}"

  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $__from"

  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  shellmock_expect kubectl --status 0 --match "config use-context " \
    "$__current_context"

  shellmock_expect touch --status 1 --match "$__resource.$__output" \
    --output "fail"

  run ${command}

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

  __unsuccess_with_param_f_or_from_touch_fail "$__command -f" $context
}

@test "kubeio with --from unsuccess touch fail" {
  local context="xpto1"

  __unsuccess_with_param_f_or_from_touch_fail "$__command --from" $context
}

function __unsuccess_with_param_f_or_from_touch_fail () {
  local context="${2}"

  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$__current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $context"

  shellmock_expect kubectl --status 0 --match "$__args" --output "xpto2"

  shellmock_expect kubectl --status 0 --match "config use-context " \
    "$__current_context"

  local command="${1} "$context

  run ${command}

  [ "$status" -eq 0 ]
  [ "$output" = "'$__resource.$__output' file saved successfully" ]

  local content=$(cat "$__file")
  [ "$content" = "xpto2" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $context" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $__current_context" ]
}
