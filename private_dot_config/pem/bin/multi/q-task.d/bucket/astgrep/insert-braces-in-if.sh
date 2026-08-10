#!/usr/bin/env bash


INLINE_RULE="$(cat <<'EOF'
id: insert-braces-in-if
language: c
rule:
  kind: return_statement
  pattern: return $$$X ;
  inside:
    any:
      - kind: if_statement
        not:
          has:
            kind: compound_statement
      - kind: else_clause
        not:
          has:
            kind: compound_statement
fix:
  "{ return $$$X; }"
message: Insert braces around single-line if statement
EOF
)"

# echo "$INLINE_RULE"
ast-grep scan --inline-rules "$INLINE_RULE" "$@"
