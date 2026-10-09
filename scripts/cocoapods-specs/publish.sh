#!/bin/bash
# Publishes the Adapty pods of this AdaptySDK-iOS checkout to the AdaptySDK-CocoaPods-Specs repo.
#   stage --ref REF --out DIR   lint the new pods of REF into DIR; pushes nothing
#   verify --from DIR           check a staged DIR, no network
#   push --from DIR             verify, then add DIR's new specs to the spec repo in one commit and one push
#   --ref REF                   manual run: stage into a temp dir, then push (needs push access)
# Options: --specs-url URL, --ios-url URL (where release tags are checked), --skip-import-validation (stage).
# A release tag publishes with the tag as source; any other ref pins the source to its commit.
set -euo pipefail
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SPECS_URL='https://github.com/adaptyteam/AdaptySDK-CocoaPods-Specs.git'
IOS_URL='https://github.com/adaptyteam/AdaptySDK-iOS.git'
COMMAND=''
FROM=''
NEW_PODS=()
IOS_REPO=''
STAGE_REPO='adapty-specs-stage'
REF=''
OUT=''
PUSH_ARGS=()
PODS=()

die() { echo "error: $*" >&2; exit 1; }
need() { [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || die "$1 needs a value"; }
json_field() { ruby -rjson -e 'puts JSON.parse($stdin.read).fetch(ARGV[0])' "$1"; }
spec_rel() { echo "Specs/$1/$2/$1.podspec.json"; }

# Commit a release tag points to on a remote (peeled for annotated tags); empty if absent.
remote_tag_sha() {
  local refs peeled
  refs=$(git ls-remote "$1" "refs/tags/$2" "refs/tags/$2^{}") || die "cannot list tags of $1"
  peeled=$(printf '%s\n' "$refs" | awk -v r="refs/tags/$2^{}" '$2 == r { print $1 }')
  if [[ -n "$peeled" ]]; then
    echo "$peeled"
  else
    printf '%s\n' "$refs" | awk -v r="refs/tags/$2" '$2 == r { print $1 }'
  fi
}

# Fills NEW_PODS with the pods not yet in the spec repo checkout; dies on a foreign source.
classify_new() {
  local statuses pod status
  local args=(--repo "$1" --version "$2" --source "$3")
  [[ -z "${4:-}" ]] || args+=(--pods "$4")
  statuses=$(ruby "$SCRIPT_DIR/classify.rb" "${args[@]}")
  NEW_PODS=()
  while read -r pod status; do
    [[ -n "$pod" ]] || continue
    case "$status" in
      new) NEW_PODS+=("$pod") ;;
      skip) echo "skip: $pod $2 is already published from the same source" ;;
      *) die "$pod $2 is already published from another source; published versions are immutable" ;;
    esac
  done <<< "$statuses"
}

# CocoaPods in the throwaway repos dir; the local commits it makes there are never pushed.
stage_pod() {
  CP_REPOS_DIR="$WORK/repos" \
    GIT_AUTHOR_NAME=publish.sh GIT_AUTHOR_EMAIL=publish.sh@localhost \
    GIT_COMMITTER_NAME=publish.sh GIT_COMMITTER_EMAIL=publish.sh@localhost \
    pod "$@"
}

stage_phase() {
  [[ -n "$REF" && -n "$OUT" ]] || die "stage needs --ref and --out"
  [[ ! -e "$OUT" ]] || die "$OUT already exists"
  local sha version='' v mode source clone pod spec rel pods_out
  IOS_REPO=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel) || die "$SCRIPT_DIR is not inside a git checkout"
  pods_out=$(ruby "$SCRIPT_DIR/pods.rb") || die "cannot read the pod list"
  PODS=()
  while IFS= read -r pod; do [[ -z "$pod" ]] || PODS+=("$pod"); done <<< "$pods_out"
  [[ ${#PODS[@]} -gt 0 ]] || die "empty pod list"
  sha=$(git -C "$IOS_REPO" rev-parse --verify --quiet "$REF^{commit}") || die "unknown ref $REF"

  # Podspecs are read at the ref, not from the working tree, and must share one version.
  for pod in "${PODS[@]}"; do
    git -C "$IOS_REPO" show "$sha:$pod.podspec" > "$WORK/$pod.podspec" 2>/dev/null \
      || die "missing $pod.podspec at $REF"
    pod ipc spec "$WORK/$pod.podspec" > "$WORK/$pod.orig.json"
    v=$(json_field version < "$WORK/$pod.orig.json")
    if [[ -z "$version" ]]; then
      version=$v
    elif [[ "$v" != "$version" ]]; then
      die "$pod is $v, expected $version (podspec versions drifted at $REF)"
    fi
  done

  # Lint clones the source from GitHub, so it must be reachable there before minutes of linting.
  if git -C "$IOS_REPO" show-ref --verify --quiet "refs/tags/$REF"; then
    mode=tag
    [[ "$REF" == "$version" ]] || die "tag $REF does not match podspec version $version"
    [[ "$(remote_tag_sha "$IOS_URL" "$REF")" == "$sha" ]] || die "tag $REF on $IOS_URL does not point to $sha"
  else
    mode=commit
    # Uses the locally known remote branches; run `git fetch` if this looks stale.
    [[ -n "$(git -C "$IOS_REPO" branch -r --contains "$sha")" ]] \
      || die "commit $sha is not on any remote branch; push it first"
  fi
  source=$(ruby -r"$SCRIPT_DIR/pods" -rjson -e 'puts JSON.generate(AdaptyPods.expected_source(*ARGV))' \
    "$mode" "$REF" "$sha")

  for pod in "${PODS[@]}"; do
    spec="$WORK/$pod.podspec.json"
    if [[ "$mode" == commit ]]; then
      ruby "$SCRIPT_DIR/rewrite_source.rb" --commit "$sha" < "$WORK/$pod.orig.json" > "$spec"
    else
      cp "$WORK/$pod.orig.json" "$spec"
    fi
    ruby -rjson -e 'exit(JSON.parse(File.read(ARGV[0]))["source"] == JSON.parse(ARGV[1]))' "$spec" "$source" \
      || die "$pod.podspec source is not $source"
  done

  stage_pod repo add "$STAGE_REPO" "$SPECS_URL" main > /dev/null
  clone="$WORK/repos/$STAGE_REPO"
  # `pod repo push` pulls before every pod; rebase keeps the local commits when main moves.
  git -C "$clone" config pull.rebase true

  classify_new "$clone" "$version" "$source"
  if [[ ${#NEW_PODS[@]} -eq 0 ]]; then
    echo "Nothing to publish: $version is already published from $mode $REF"
    return 0
  fi

  echo "Staging $version from $REF ($mode source, $sha): ${NEW_PODS[*]}"
  for pod in "${NEW_PODS[@]}"; do
    echo "lint: $pod $version"
    # Only the spec repo is a source: a missing Adapty dependency must fail, not resolve from trunk.
    stage_pod repo push "$STAGE_REPO" "$WORK/$pod.podspec.json" \
      --sources="$STAGE_REPO" \
      --local-only --no-overwrite --allow-warnings --skip-tests \
      --commit-message="[Add] $pod ($version)" \
      ${PUSH_ARGS[@]+"${PUSH_ARGS[@]}"}
  done

  for pod in "${NEW_PODS[@]}"; do
    rel=$(spec_rel "$pod" "$version")
    mkdir -p "$OUT/$(dirname "$rel")"
    cp "$clone/$rel" "$OUT/$rel"
  done
  ruby -rjson -e 'puts JSON.pretty_generate("version" => ARGV[0], "mode" => ARGV[1], "ref" => ARGV[2],
                                            "sha" => ARGV[3], "pods" => ARGV[4..])' \
    "$version" "$mode" "$REF" "$sha" "${NEW_PODS[@]}" > "$OUT/manifest.json"
  ruby "$SCRIPT_DIR/verify_artifact.rb" "$OUT" > /dev/null
  echo "Staged $version: ${NEW_PODS[*]} -> $OUT"
}

verify_phase() {
  [[ -n "$FROM" ]] || die "verify needs --from DIR"
  ruby "$SCRIPT_DIR/verify_artifact.rb" "$FROM"
}

push_phase() {
  [[ -n "$FROM" ]] || die "push needs --from DIR"
  local manifest version mode ref sha source pods_csv clone attempt=1 pod rel body
  manifest=$(ruby "$SCRIPT_DIR/verify_artifact.rb" "$FROM") || exit 1
  version=$(json_field version <<< "$manifest")
  mode=$(json_field mode <<< "$manifest")
  ref=$(json_field ref <<< "$manifest")
  sha=$(json_field sha <<< "$manifest")
  pods_csv=$(ruby -rjson -e 'puts JSON.parse($stdin.read).fetch("pods").join(",")' <<< "$manifest")
  source=$(ruby -r"$SCRIPT_DIR/pods" -rjson -e 'puts JSON.generate(AdaptyPods.expected_source(*ARGV))' \
    "$mode" "$ref" "$sha")

  if [[ "$mode" == tag ]]; then
    [[ "$(remote_tag_sha "$IOS_URL" "$ref")" == "$sha" ]] || die "tag $ref on $IOS_URL does not point to $sha"
  fi

  body="Source: $mode $ref ($sha)"
  if [[ -n "${GITHUB_RUN_ID:-}" ]]; then
    body="$body"$'\n'"Run: ${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
  fi

  clone="$WORK/specs"
  git clone --quiet --branch main "$SPECS_URL" "$clone" || die "cannot clone $SPECS_URL"
  while :; do
    git -C "$clone" fetch --quiet origin main
    git -C "$clone" reset --quiet --hard origin/main
    classify_new "$clone" "$version" "$source" "$pods_csv"
    if [[ ${#NEW_PODS[@]} -eq 0 ]]; then
      echo "Nothing to publish: $version is already published from $mode $ref"
      return 0
    fi
    for pod in "${NEW_PODS[@]}"; do
      rel=$(spec_rel "$pod" "$version")
      mkdir -p "$clone/$(dirname "$rel")"
      cp "$FROM/$rel" "$clone/$rel"
    done
    git -C "$clone" add Specs
    git -C "$clone" commit --quiet -m "[Add] Adapty pods ($version)" -m "$body"
    if git -C "$clone" push --quiet origin HEAD:refs/heads/main; then
      break
    fi
    [[ $attempt -lt 3 ]] || die "cannot push to $SPECS_URL after 3 attempts"
    attempt=$((attempt + 1))
    echo "push rejected, retrying ($attempt/3)" >&2
  done

  [[ "$(git -C "$clone" ls-remote origin refs/heads/main | cut -f1)" == "$(git -C "$clone" rev-parse HEAD)" ]] \
    || die "$SPECS_URL main does not match the pushed commit"
  echo "Published $version ($mode $ref, $sha): ${NEW_PODS[*]}"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    stage|verify|push) [[ -z "$COMMAND" ]] || die "unexpected $1"; COMMAND=$1; shift ;;
    --ref) need "$@"; REF=$2; shift 2 ;;
    --out) need "$@"; OUT=$2; shift 2 ;;
    --from) need "$@"; FROM=$2; shift 2 ;;
    --specs-url) need "$@"; SPECS_URL=$2; shift 2 ;;
    --ios-url) need "$@"; IOS_URL=$2; shift 2 ;;
    --skip-import-validation) PUSH_ARGS+=(--skip-import-validation); shift ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

case "$COMMAND" in
  stage) stage_phase ;;
  verify) verify_phase ;;
  push) push_phase ;;
  '')
    [[ -n "$REF" ]] || die "a command or --ref is required (see --help)"
    OUT="$WORK/staged"
    stage_phase
    [[ -f "$OUT/manifest.json" ]] || exit 0
    FROM="$OUT"
    push_phase
    ;;
esac
