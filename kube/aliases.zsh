alias k='kubectl'
alias kubectl-pod-name='kubectl get pod -o jsonpath="{.items[0].metadata.name}"'

function kubectl-exec() {
  local pod_name="$(kubectl-pod-name -l app=$1)"
  shift
  kubectl exec -i -t $pod_name "$@"
}
