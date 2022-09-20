#!/bin/sh
set -e

base_dir=$(dirname "$(realpath "$0")" )

test_context=$1
original_context=$(kubectl config current-context)
chart_dir="${base_dir}/chart"
tests_dir="${base_dir}/tests"

namespaces_to_be_deleted=""
cleanup() {
  if [ -n "${cleaning_up}" ]; then
    return
  fi
  cleaning_up=1

  echo "[CLEANUP] Clean our mess before terminating"
  for ns_tbd in $namespaces_to_be_deleted; do
    echo "[CLEANUP] Deleting namespace ${ns_tbd}"
    kubectl delete namespace "${ns_tbd}" > /dev/null
  done

  if [ -n "${working_dir}" ]; then
    echo "[CLEANUP] Deleting working directory"
#    rm -r "${working_dir}" > /dev/null
    echo "WORKING DIRECTORY : ${working_dir}"
  fi

  echo "[CLEANUP] Cleaning done"
}
trap 'cleanup' 0 1 2 6

if [ -z "${test_context}" ]; then
  target_context="${original_context}"
else
  target_context="${test_context}"
fi

run_id=$RANDOM
ns_test="ns-test-${run_id}"
ns_test_bis="ns-test-bis-${run_id}"


# Present warning to user
echo "This script will interact with the cluster define in context '${target_context}'. You can use another context by"
echo "passing its name on first argument to this script. Namespaces '${ns_test}' and '${ns_test_bis}' will be used; "
echo "if those namespaces do not exist, they will be created at the begin and deleted at the end."
echo
echo "Please review configuration for context '${target_context}' before proceeding :"
kubectl config get-contexts "${target_context}"
echo
echo "Press Enter to continue"
# shellcheck disable=SC2162
read
echo "[ SETUP ] Prepare local & remote environments for tests"

echo "[ SETUP ] Define aliases"
# shellcheck disable=SC2139
alias kubectl="kubectl --context=${target_context} --namespace=${ns_test}"
# shellcheck disable=SC2139
alias helm="helm --kube-context=${target_context} --namespace=${ns_test}"

printf "[ SETUP ]   alias %s\n" "$(alias kubectl)"
printf "[ SETUP ]   alias %s\n" "$(alias helm)"

echo "[ SETUP ] Creating working directory"
working_dir=$(mktemp -d)

echo "[ SETUP ] Update chart dependencies"
helm dependencies update "${chart_dir}" > /dev/null

# Check namespace existence, creating it if necessary and remembering action
existing_namespaces=$(kubectl get namespaces -o name)
create_ns() {
  ns="$1"
  namespaces_to_be_deleted="${ns} ${namespaces_to_be_deleted}"

  echo "[ SETUP ] Creating namespace '${ns}'"
  kubectl create namespace "${ns}" > /dev/null
}

ensure_ns() {
  ns="$1"
  echo "${existing_namespaces}" | grep -F -q -x "namespace/${ns}" || create_ns "${ns}"
}

ensure_ns "${ns_test}"
ensure_ns "${ns_test_bis}"

echo "[ SETUP ] Environments ready for tests"
echo

# Install trap for namespace deletion, if necessary

for test in "${tests_dir}"/*.d; do

  test_name=$(basename "${test}")
  test_name=${test_name%'.d'}
  test_name=${test_name#??_}
  test_working_dir="${working_dir}/${test_name}"
  release_name="release-test-${run_id}"

  echo_prefix="[TESTING][${test_name}]"

  echo "${echo_prefix} Creating test working directory and entering it"
  mkdir -p "${test_working_dir}"
  cd "${test_working_dir}"

  echo "${echo_prefix} Running test"

  echo "${echo_prefix} Installing release"
  helm install "${release_name}" "${chart_dir}" -f "${test}/first_install.yaml" > /dev/null
  echo "${echo_prefix} Getting installed objects"
  kubectl get configmap test -o yaml > installed-configmap.yaml
  kubectl get secret test -o yaml > installed-secret.yaml
  kubectl get configmap test-force-update -o yaml > installed-test-force-update.yaml

  echo "${echo_prefix} Upgrading release"
  helm upgrade "${release_name}" "${chart_dir}" -f "${test}/upgrade.yaml" > /dev/null
  echo "${echo_prefix} Getting upgraded objects"
  kubectl get configmap test -o yaml > upgraded-configmap.yaml
  kubectl get secret test -o yaml > upgraded-secret.yaml
  kubectl get configmap test-force-update -o yaml > upgraded-test-force-update.yaml

  # shellcheck source=tests/00_basic.d/assert.sh
  . "${test}/assert.sh"

  if [ -f "failure.txt" ]; then
    echo "${echo_prefix} Failure :"
    cat "failure.txt"
  else
    echo "${echo_prefix} Success"
  fi

  echo "${echo_prefix} Uninstalling chart"
  helm uninstall "${release_name}" > /dev/null
  echo
done

# For each test
  # Copy chart/ to temp
  # run before_first_install
  # Install first release
  # run after_first_install
  # Upgrade release
  # run after_upgrade
  # Uninstall release
