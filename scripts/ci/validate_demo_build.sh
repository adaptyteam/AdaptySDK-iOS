#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  validate_demo_build.sh --log <path> --ignored-json '<json-array>'

Example:
  validate_demo_build.sh \
    --log xcodebuild.log \
    --ignored-json '[{"message":"Known error message","file":"Sources/File.swift","line":12}]'
EOF
}

log_path=""
ignored_json=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --log)
      if [[ $# -lt 2 ]]; then
        echo "Error: --log requires an argument" >&2
        exit 1
      fi
      log_path="$2"
      shift 2
      ;;
    --ignored-json)
      if [[ $# -lt 2 ]]; then
        echo "Error: --ignored-json requires an argument" >&2
        exit 1
      fi
      ignored_json="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$log_path" || -z "$ignored_json" ]]; then
  echo "Both --log and --ignored-json are required." >&2
  usage
  exit 1
fi

if [[ ! -f "$log_path" ]]; then
  echo "Log file does not exist: $log_path" >&2
  exit 1
fi

node - "$log_path" "$ignored_json" <<'NODE'
const fs = require("node:fs");

const logPath = process.argv[2];
const ignoredRaw = process.argv[3];

const fail = (message) => {
  console.error(message);
  process.exit(1);
};

const normalizeFile = (filePath) => {
  return filePath.replace(/\\/g, "/").trim();
};

const normalizeMessage = (message) => {
  return message
    .replace(/\s+\(in target .*$/, "")
    .trim();
};

const parseRule = (entry, index) => {
  if (typeof entry === "string") {
    if (entry.trim() === "") {
      fail(`ignored error at index ${index} must be a non-empty string.`);
    }

    return { message: normalizeMessage(entry), file: null, line: null };
  }

  if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
    fail(`ignored error at index ${index} must be a string or an object.`);
  }

  const { message, file, line } = entry;
  if (typeof message !== "string" || message.trim() === "") {
    fail(`ignored error at index ${index} has invalid 'message'.`);
  }

  const normalizedRule = {
    message: normalizeMessage(message),
    file: null,
    line: null,
  };

  if (file !== undefined) {
    if (typeof file !== "string" || file.trim() === "") {
      fail(`ignored error at index ${index} has invalid 'file'.`);
    }
    normalizedRule.file = normalizeFile(file);
  }

  if (line !== undefined) {
    if (!Number.isInteger(line) || line <= 0) {
      fail(`ignored error at index ${index} has invalid 'line'.`);
    }
    if (normalizedRule.file === null) {
      fail(`ignored error at index ${index} cannot specify 'line' without 'file'.`);
    }
    normalizedRule.line = line;
  }

  return normalizedRule;
};

const parseErrorLine = (line) => {
  const withFile = line.match(/^(.+?):(\d+):(?:\d+:)?\s*error:\s*(.*)$/);
  if (withFile) {
    const message = normalizeMessage(withFile[3]);
    if (message.length === 0) return null;

    return {
      file: normalizeFile(withFile[1]),
      line: Number(withFile[2]),
      message,
    };
  }

  const topLevelError = line.match(/^\s*(?:xcodebuild:\s*)?error:\s*(.*)$/);
  if (!topLevelError) return null;

  const message = normalizeMessage(topLevelError[1]);
  if (message.length === 0) return null;
  if (message === "fatalError") return null;

  return {
    file: null,
    line: null,
    message,
  };
};

const fileMatches = (ruleFile, actualFile) => {
  if (!ruleFile) return true;
  if (!actualFile) return false;
  if (actualFile === ruleFile) return true;
  return actualFile.endsWith(`/${ruleFile}`);
};

const ruleMatches = (errorEntry, rule) => {
  if (errorEntry.message !== rule.message) return false;
  if (!fileMatches(rule.file, errorEntry.file)) return false;
  if (rule.line !== null && errorEntry.line !== rule.line) return false;
  return true;
};

const formatError = (errorEntry) => {
  const location = errorEntry.file
    ? `${errorEntry.file}${errorEntry.line !== null ? `:${errorEntry.line}` : ""}: `
    : "";
  return `${location}${errorEntry.message}`;
};

const secondarySummaryPatterns = [
  /^(?:emit-module|compile|frontend|swift-frontend) command failed(?: with exit code \d+| due to signal \d+).*$/i,
];

const isSecondarySummary = (errorEntry) => {
  if (errorEntry.file !== null) return false;
  return secondarySummaryPatterns.some((pattern) => pattern.test(errorEntry.message));
};

let ignored;
try {
  ignored = JSON.parse(ignoredRaw);
} catch (error) {
  fail(`Failed to parse --ignored-json: ${error.message}`);
}

if (!Array.isArray(ignored)) {
  fail("--ignored-json must be a JSON array.");
}

const ignoredRules = ignored.map(parseRule);

let logContent;
try {
  logContent = fs.readFileSync(logPath, "utf8");
} catch (error) {
  fail(`Failed to read log file: ${error.message}`);
}

const parsedErrors = [];
for (const line of logContent.split(/\r?\n/)) {
  const parsed = parseErrorLine(line);
  if (parsed) parsedErrors.push(parsed);
}

if (parsedErrors.length === 0) {
  fail("Command failed but no parseable `error:` lines were found in the log.");
}

const uniqueErrors = [
  ...new Map(
    parsedErrors.map((entry) => [
      `${entry.file ?? ""}|${entry.line ?? ""}|${entry.message}`,
      entry,
    ])
  ).values(),
];

const hasFileDiagnostics = uniqueErrors.some((entry) => entry.file !== null);
const relevantErrors = hasFileDiagnostics
  ? uniqueErrors.filter((entry) => !isSecondarySummary(entry))
  : uniqueErrors;

const unexpected = relevantErrors.filter(
  (entry) => !ignoredRules.some((rule) => ruleMatches(entry, rule))
);

if (unexpected.length > 0) {
  console.error("Unexpected errors found in log:");
  for (const entry of unexpected) {
    console.error(`- ${formatError(entry)}`);
  }
  process.exit(1);
}

console.log("::warning::Command failed but only contained known/ignored errors.");
for (const entry of relevantErrors) {
  console.log(`- ${formatError(entry)}`);
}
NODE
