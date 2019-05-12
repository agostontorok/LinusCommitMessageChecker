#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Set up stubs for faking TTY input
export FAKE_TTY="$BATS_TMPDIR/fake_tty"
function tty() { echo $FAKE_TTY; }
export -f tty

# Remember where the hook is
BASE_DIR=$(dirname $BATS_TEST_DIRNAME)
# Set up a directory for our git repo
TMP_DIRECTORY=$(mktemp -d)

setup() {
  # Clear initial TTY input
  echo "" > $FAKE_TTY

  # Set up a git repo
  cd $TMP_DIRECTORY
  git init
  git config user.email "test@git-confirm"
  git config user.name "Git Confirm Tests"
  cp "$BASE_DIR/hook.sh" ./.git/hooks/commit-msg
}

teardown() {
  if [ $BATS_TEST_COMPLETED ]; then
    echo "Deleting $TMP_DIRECTORY"
    rm -rf $TMP_DIRECTORY
  else
    echo "** Did not delete $TMP_DIRECTORY, as test failed **"
  fi

  cd $BATS_TEST_DIRNAME
}

@test "Should let you make normal all-good commits" {
  echo "Some content" > my_file
  git add my_file
  run git commit -m "Add content"
  assert_success
  refute_line --partial "This commit message does not conform our policy"
}


@test "Should not let messages not starting with capital letter" {
  echo "Some content" > my_file
  git add my_file
  run git commit -m "content"
  echo "Some content" >> my_file && git add my_file
  assert_failure
  run git commit -m "content\nContent"
  echo "Some content" >> my_file && git add my_file
  assert_failure
  run git commit -m "lowercase letter Capital letter"
  assert_failure
  refute_line --partial "my_file additions match 'TODO'"
}


@test "Should not let messages not starting action verbs such as Add, Remove, Modify" {
  echo "Some content" > my_file
  git add my_file
  run git commit -m "Vary"
  echo "Some content" >> my_file && git add my_file
  assert_failure
  run git commit -m "Burn"
  echo "Some content" >> my_file && git add my_file
  assert_failure
  run git commit -m "Download"
  assert_failure
  refute_line --partial "my_file additions match 'TODO'"
}