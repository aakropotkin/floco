#! /usr/bin/env bash

# NOTE: This script is a draft.

: "${JQ:=jq}";

declare -a fields;
fields=();

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -d|--deps|--dependencies)
      fields+=( dependencies devDependencies );
      : "${JOIN_DEPS=:}";
    ;;
    -p|--prod|--prod-deps|--proddeps|--prod-dependencies)
      fields+=( dependencies );
    ;;
    -D|--dev|--dev-deps|--devdeps|--dev-dependencies)
      fields+=( devDependencies );
    ;;
    -o|--override|--overrides)
      fields+=( overrides );
    ;;
    -j|--join-deps)
      JOIN_DEPS=:;
    ;;
    -J|--no-join-deps)
      JOIN_DEPS=;
    ;;
    *)
      fields+=( "$1" );
    ;;
  esac
  shift;
done

_cmd='{';

for f in "${fields[@]}"; do
  _cmd+="\"$f\":.[\"$f\"],"
done
_cmd="${_cmd%,}}";

if [[ -n "${JOIN_DEPS:-}" ]]; then
  _cmd+='|.+={
      dependencies: ( ( .dependencies // {} ) + ( .devDependencies // {} ) )
    }|del( .devDependencies )';
  if [[ "${#fields[@]}" -eq 2 ]]; then
    _cmd+='|.dependencies';
  fi
fi

$JQ "$_cmd" ./package.json;
