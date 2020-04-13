#!/usr/bin/env bats

__name="deployment"
__type="yaml"
__args="get $__name -o $__type"
__command="$BATS_TEST_DIRNAME/../kubeimp"
__command_full="$__command -n $__name -t $__type"

#kubectl get $__name -o $__type

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

@test "kubectl is not installed" {
  shellmock_expect kubectl --status 127 --match "$__args"

  run ${__command_full}

  [ "$status" -eq 127 ]
  [ "$output" = "kubectl is not installed" ]
}

@test "kubeimp faill" {
  shellmock_expect kubectl --status 2 --match "$__args" --output "Any Error"

  run ${__command_full}

  [ "$status" -eq 2 ]
  [ "$output" = "Any Error" ]
}

@test "kubeimp success" {
  shellmock_expect kubectl --status 0 --match "$__args" --output "Success"

  run ${__command_full}

  [ "$status" -eq 0 ]
  [ "$output" = "Success" ]
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

@test "kubeimp without arguments" {
  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the -n parameter" {
  local command="$__command -n"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the --name parameter" {
  local command="$__command --name"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the -t parameter" {
  local command="$__command -t"

  run ${__command}

  [ "$status" -eq 1 ]
}

@test "kubeimp only the --type parameter" {
  local command="$__command --type"

  run ${__command}

  [ "$status" -eq 1 ]
}
