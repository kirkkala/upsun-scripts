#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  VERSION="$(grep '^VERSION=' "$REPO_ROOT/src/upsun-scripts-common.sh" | cut -d'"' -f2)"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/upsun" << EOF
#!/bin/bash
echo "\$*" > "$BATS_TEST_TMPDIR/cmd"
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/upsun"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

# Empty git repo with a fake Upsun project link.
fake_project() {
  local dir="$BATS_TEST_TMPDIR/project"
  mkdir -p "$dir/.upsun/local"
  touch "$dir/.upsun/local/project.yaml"
  git -C "$dir" init -q -b "${1:-main}"
  echo "$dir"
}

@test "upsun-db-dump --version" {
  run "$REPO_ROOT/src/upsun-db-dump" --version
  [ "$status" -eq 0 ]
  [ "$output" = "upsun-db-dump $VERSION — Kirkkala's Upsun scripts" ]
}

@test "upsun-db-dump --help" {
  run "$REPO_ROOT/src/upsun-db-dump" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"USAGE"* ]]
  [[ "$output" == *"upsun-db-dump"* ]]
}

@test "upsun-check-traffic --version" {
  run "$REPO_ROOT/src/upsun-check-traffic" --version
  [ "$status" -eq 0 ]
  [ "$output" = "upsun-check-traffic $VERSION — Kirkkala's Upsun scripts" ]
}

@test "upsun-check-traffic --help" {
  run "$REPO_ROOT/src/upsun-check-traffic" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"USAGE"* ]]
  [[ "$output" == *"upsun-check-traffic"* ]]
}

@test "upsun-check-traffic unknown option fails" {
  run "$REPO_ROOT/src/upsun-check-traffic" --nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "upsun-db-dump runs db:dump for the current branch into db_dumps" {
  cd "$(fake_project my-branch)"
  run "$REPO_ROOT/src/upsun-db-dump"
  [ "$status" -eq 0 ]

  cmd=$(cat "$BATS_TEST_TMPDIR/cmd")
  echo "upsun $cmd" >&3
  [[ "$cmd" == *"db:dump"* ]]
  [[ "$cmd" == *"--environment=my-branch"* ]]
  [[ "$cmd" == *"/db_dumps/"* ]]
  [[ "$cmd" == *".sql"* ]]
  [[ "$cmd" != *"db:drop"* ]]
  [[ "$cmd" != *"e:ssh"* ]]
  [[ "$cmd" != *"--environment=main"* ]]
}

@test "upsun-db-dump keeps slashes in the environment, not in the filename" {
  cd "$(fake_project feature/foo)"
  run "$REPO_ROOT/src/upsun-db-dump"
  [ "$status" -eq 0 ]

  cmd=$(cat "$BATS_TEST_TMPDIR/cmd")
  echo "upsun $cmd" >&3
  [[ "$cmd" == *"--environment=feature/foo"* ]]
  [[ "$cmd" == *"feature-foo.sql"* ]]
  [[ "$cmd" != *"/feature/foo.sql"* ]]
}

@test "upsun-db-dump uses drupal/db_dumps when that directory exists" {
  project=$(fake_project main)
  mkdir -p "$project/drupal/db_dumps"
  cd "$project"
  run "$REPO_ROOT/src/upsun-db-dump"
  [ "$status" -eq 0 ]

  cmd=$(cat "$BATS_TEST_TMPDIR/cmd")
  echo "upsun $cmd" >&3
  [[ "$cmd" == *"/drupal/db_dumps/"* ]]
}

@test "upsun-check-traffic SSHs to main and greps access.log for the given hour" {
  cd "$(fake_project feature/foo)"
  run "$REPO_ROOT/src/upsun-check-traffic" "20/Nov/2025:07"
  [ "$status" -eq 0 ]

  cmd=$(cat "$BATS_TEST_TMPDIR/cmd")
  echo "upsun $cmd" >&3
  [[ "$cmd" == *"e:ssh"* ]]
  [[ "$cmd" == *"-e main"* ]]
  [[ "$cmd" == *"/var/log/access.log"* ]]
  [[ "$cmd" == *"20\\/Nov\\/2025:07"* ]]
  [[ "$cmd" != *"db:dump"* ]]
  [[ "$cmd" != *"-e feature/foo"* ]]
}
