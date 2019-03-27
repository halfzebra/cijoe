#!/usr/bin/env bash
#
# selftest: running tests of CIJOE using CIJOE
#
# * Sources in CIJOE
# * Creates local environment definition $res_dpath/selftest_env.sh
# * Invokes the cij_runner
# * Generates report(s) using cij_reporter and cij_testcases
#

# shellcheck source=modules/cijoe.sh
cij_setup() {
  CIJ_ROOT=$(cij_root)
  export CIJ_ROOT

  pushd "$CIJ_ROOT" || exit 1
  source modules/cijoe.sh
  if ! source "$CIJ_ROOT/modules/cijoe.sh"; then
    echo "Bad mojo"
    exit
  fi
  popd || exit 1
}

main() {
  local res=0

  cij_setup

  open="$1"
  res_dpath="$2"

  # Create directory to store results
  : "${res_dpath:=$(mktemp -d trun.XXXXXX -p /tmp)}"
  : "${env_fpath:=$res_dpath/selftest_env.sh}"
  : "${tplan_fpath:=$CIJ_TESTPLANS/cijoe.plan}"
  rmdir "$res_dpath" || true
  mkdir "$res_dpath"

  cij::info "# res_dpath: '$res_dpath'"
  cij::info "# tplan_fpath: '$tplan_fpath'"
  cij::info "# env_fpath: '$env_fpath'"

  # Create the environment
  cat "$CIJ_ENVS/localhost.sh" > "$env_fpath"
  echo "export CIJ_REPOS=\"$PWD\"" >> "$env_fpath"

  # Start the runner
  if ! cij_runner "$tplan_fpath" "$env_fpath" --output "$res_dpath" -vvv; then
    cij::err "cij_runner encountered an error"
    res=$(( res + 1 ))
  fi

  # Create test report
  if ! cij_reporter "$res_dpath"; then
    cij::err "cij_reporter encountered an error"
    res=$(( res + 1 ))
  fi

  # Create testcases report
  if ! cij_testcases --output "$res_dpath"; then
    cij::err "cij_testcases encountered an error"
    res=$(( res + 1 ))
  fi

  if [[ $open -gt 0 ]]; then
    xdg-open "$res_dpath/testcases.html" &
    xdg-open "$res_dpath/report.html" &
  fi

  cij::info "res: '$res'"

  exit $res
}

main "$@"
