#!/usr/bin/env bash
set -euo pipefail

# Token-based Vercel workflow helper.
#
# Required environment variables:
#   VERCEL_TOKEN   - Vercel personal access token
# Optional:
#   VERCEL_TEAM    - team slug or ID (defaults to personal account)
#   VERCEL_PROJECT - project name or slug (defaults to vws-linked-execution-app)
#
# Usage:
#   export VERCEL_TOKEN=...
#   ./scripts/vercel-workflow.sh status
#   ./scripts/vercel-workflow.sh deployments
#   ./scripts/vercel-workflow.sh inspect

PROJECT="${VERCEL_PROJECT:-vws-linked-execution-app}"
TEAM="${VERCEL_TEAM:-}"
CMD="${1:-status}"

if [[ -z "${VERCEL_TOKEN:-}" ]]; then
  echo "ERROR: VERCEL_TOKEN is required" >&2
  exit 1
fi

api() {
  local path="$1"
  curl -fsS \
    -H "Authorization: Bearer ${VERCEL_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.vercel.com${path}"
}

team_qs() {
  if [[ -n "$TEAM" ]]; then
    printf '?teamId=%s' "$TEAM"
  fi
}

project_json() {
  api "/v9/projects$(team_qs)" | python3 -c 'import json,sys; name=sys.argv[1]; obj=json.load(sys.stdin); projects=obj.get("projects", []); [print(json.dumps(p)) for p in projects if p.get("name") == name] or sys.exit(f"Project not found: {name}")' "$PROJECT"
}

project_id() {
  project_json | python3 -c 'import sys, json; print(json.load(sys.stdin)["id"])'
}

case "$CMD" in
  status)
    api "/v9/projects/${PROJECT}$(team_qs)" | python3 - <<'PY'
import sys, json
obj = json.load(sys.stdin)
print(f"Project: {obj.get('name')}")
print(f"ID: {obj.get('id')}")
print(f"Framework: {obj.get('framework')}")
print(f"Created: {obj.get('createdAt')}")
print(f"Updated: {obj.get('updatedAt')}")
print(f"Git repo: {obj.get('link', {}).get('repoId', 'n/a')}")
print(f"Production URL: {obj.get('latestDeployments', [{}])[0].get('url') if obj.get('latestDeployments') else 'n/a'}")
PY
    ;;
  deployments)
    pid="$(project_id)"
    api "/v6/deployments?projectId=${pid}$(team_qs)" | python3 - <<'PY'
import sys, json
obj = json.load(sys.stdin)
for d in obj.get('deployments', [])[:10]:
    print(f"{d.get('uid')}\t{d.get('state')}\t{d.get('meta', {}).get('githubCommitMessage', '')}\t{d.get('createdAt')}")
PY
    ;;
  inspect)
    pid="$(project_id)"
    api "/v6/deployments?projectId=${pid}$(team_qs)" | python3 - <<'PY'
import sys, json
obj = json.load(sys.stdin)
for d in obj.get('deployments', [])[:1]:
    print(json.dumps(d, indent=2, sort_keys=True))
PY
    ;;
  *)
    echo "Usage: $0 {status|deployments|inspect}" >&2
    exit 2
    ;;
esac
