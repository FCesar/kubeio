#!/usr/bin/env bats

__kcov="kcov --exclude-path=coverage/,tests/,.travis.yml,.git/,~/bin,$BATS_TEST_DIRNAME/../kubeio coverage"

__command="$BATS_TEST_DIRNAME/../install.sh"

setup() {
  . shellmock
  shellmock_clean
}

teardown()
{
  if [ "$__command" != "" ] ; then
    $__kcov $__command
  fi

  if [ -z "$TEST_FUNCTION" ] ; then
    shellmock_clean
  fi
}

@test "install.sh fail" {
  run ${__command}

  local expected="usage: ${__command} <prefix> e.g. ${__command} /usr/local"

  expected=$(echo -e $expected | md5sum)

  output=$(echo -e $output | md5sum)

  [ "$status" -eq 1 ]
  [[ "$output" = $expected ]]
}

@test "install.sh success" {
  local prefix="/tmp"

  shellmock_expect mkdir --status 0 --match "-p $prefix/bin"

  shellmock_expect cp --status 0 --match "kubeio $prefix/bin/"

  local command="$__command $prefix"

  __command=$command

  run ${command}

  local expected="Installed kubeio to $prefix/bin/kubeio"

  expected=$(echo -e $expected | md5sum)

  output=$(echo -e $output | md5sum)
  echo $status
  [ "$status" -eq 0 ]
  [[ "$output" = $expected ]]
}
