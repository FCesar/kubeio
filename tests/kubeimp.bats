#!/usr/bin/env bats

__from="minikube"

__namespace="default"

__resource="all"

__output="json"

__args="get $__resource -o $__output -n $__namespace"

__command="$BATS_TEST_DIRNAME/../kubeimp"

__command_short="$__command -f $__from -n $__namespace -r $__resource \
    -o $__output"

__command_full="$__command --from $__from --namespace $__namespace \
    --resource $__resource --output $__output"

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

@test "kubeimp without arguments" {
  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp -h" {
  local command="$__command -h"

  run ${command}

  [ "$status" -eq 0 ]
}

@test "kubeimp --help" {
  local command="$__command --help"

  run ${command}

  [ "$status" -eq 0 ]
}

@test "kubeimp with -f" {
  local context="xpto1"

  __with_param_f_or_full "$__command -f" $context
}

@test "kubeimp with --from" {
  local context="xpto1"

  __with_param_f_or_full "$__command --from" $context
}

function __with_param_f_or_full() {
  local current_context="xpto0"

  local context="${2}"

  shellmock_expect kubectl --status 0 --match "config current-context" \
    --output "$current_context"

  shellmock_expect kubectl --status 0 --match "config use-context $context"

  shellmock_expect kubectl --status 0 --match "$__args" --output "xpto2"

  shellmock_expect kubectl --status 0 --match "config use-context " \
    "$current_context"

  local command="${1} "$context

  run ${command}

  [ "$status" -eq 0 ]
  [ "$output" = "xpto2" ]

  shellmock_verify

  [ "${capture[1]}" = "kubectl-stub config current-context" ]
  [ "${capture[2]}" = "kubectl-stub config use-context $context" ]
  [ "${capture[3]}" = "kubectl-stub $__args" ]
  [ "${capture[4]}" = "kubectl-stub config use-context $current_context" ]
}

@test "kubeimp faill" {
  skip
  shellmock_expect kubectl --status 2 --match "$__args" --output "Any Error"

  run ${__command_short}

  [ "$status" -eq 2 ]
  [ "$output" = "Any Error" ]
}

@test "kubeimp success" {
  skip
  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  run ${__command_short}

  [ "$status" -eq 0 ]
  [ "$output" = "Success" ]
}

@test "kubeimp only the -n parameter" {
  local command="$__command -n"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the --namespace parameter" {
  local command="$__command --namespace"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the -o parameter" {
  local command="$__command -o"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the --output parameter" {
  local command="$__command --output"

  run ${__command}

  [ "$status" -eq 1 ]
}
