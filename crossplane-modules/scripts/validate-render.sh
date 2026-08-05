#!/usr/bin/env bash
# renders every module's compsition against its example claim. catches the
# needs: crossplane cli + docker running
set -uo pipefail
cd "$(dirname "$0")/.."

FUNCS=$(mktemp)
cat > "$FUNCS" << 'EOF'
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-patch-and-transform
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.7.0
---
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-go-templating
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.9.2
EOF
trap 'rm -f "$FUNCS"' EXIT

docker info >/dev/null 2>&1 || { echo "docker's not running, need it for crossplane render"; exit 2; }

pass=0
fail=0
for dir in modules/*/; do
  name="$(basename "$dir")"
  comp="${dir}composition.yaml"
  claim="examples/${name}-claim.yaml"
  [ -f "$comp" ] || continue
  [ -f "$claim" ] || { echo "skip $name - no example claim"; continue; }

  out="$(crossplane render "$claim" "$comp" "$FUNCS" 2>&1)"
  if [ $? -eq 0 ] && grep -q "^kind:" <<<"$out"; then
    echo "ok   $name"
    pass=$((pass+1))
  else
    echo "FAIL $name"
    echo "$out" | tail -5 | sed 's/^/     /'
    fail=$((fail+1))
  fi
done

echo "---"
echo "$pass ok, $fail failed"
[ "$fail" -eq 0 ]
