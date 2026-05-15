#!/usr/bin/env node

const fs = require("node:fs");

const {
    parseBool,
    parseJson,
    parseMatrixOverride,
    readRequiredFile,
    readWorkflowBooleanInputDefault,
    validateBoolean,
    validateMatrix,
    validateSdkTests,
} = require("./lib/config");

const main = () => {
    const configPath = ".github/ci/ci-run-config.json";
    const workflowPath = ".github/workflows/sdk-validation.yml";
    const eventName = (process.env.EVENT_NAME || "workflow_dispatch").trim();

    const config = parseJson(readRequiredFile(configPath), configPath);
    if (config.schema_version !== 2) {
        throw new Error(`Unsupported schema_version '${config.schema_version}' in ${configPath}. Expected 2.`);
    }

    if (eventName !== "workflow_dispatch" && eventName !== "pull_request") {
        throw new Error(`Unsupported event '${eventName}'. Expected workflow_dispatch or pull_request.`);
    }

    const defaultRunBuildSdkTargets = validateBoolean(config.build_sdk_targets, "build_sdk_targets");
    const defaultRunBuildTestApp = validateBoolean(config.build_test_app, "build_test_app");
    const defaultRunTests = validateBoolean(config.run_tests, "run_tests");
    const defaultRunLintPods = validateBoolean(config.lint_pods, "lint_pods");

    const workflowDefaults = {
        build_sdk_targets: readWorkflowBooleanInputDefault(workflowPath, "build_sdk_targets"),
        build_test_app: readWorkflowBooleanInputDefault(workflowPath, "build_test_app"),
        run_tests: readWorkflowBooleanInputDefault(workflowPath, "run_tests"),
        lint_pods: readWorkflowBooleanInputDefault(workflowPath, "lint_pods"),
    };

    if (workflowDefaults.build_sdk_targets !== defaultRunBuildSdkTargets) {
        throw new Error("Workflow input default for build_sdk_targets is out of sync with ci-run-config.json.");
    }
    if (workflowDefaults.build_test_app !== defaultRunBuildTestApp) {
        throw new Error("Workflow input default for build_test_app is out of sync with ci-run-config.json.");
    }
    if (workflowDefaults.run_tests !== defaultRunTests) {
        throw new Error("Workflow input default for run_tests is out of sync with ci-run-config.json.");
    }
    if (workflowDefaults.lint_pods !== defaultRunLintPods) {
        throw new Error("Workflow input default for lint_pods is out of sync with ci-run-config.json.");
    }

    const defaultBuildMatrix = validateMatrix(config.build_matrix, "build_matrix");
    const defaultSdkTestsMatrix = validateMatrix(config.sdk_tests_matrix, "sdk_tests_matrix");
    const sdkTests = validateSdkTests(config.sdk_tests);

    const parseEffectiveBool = (raw, defaultValue, label) =>
        eventName === "pull_request" ? defaultValue : parseBool(raw, defaultValue, label);

    const runBuildSdkTargets = parseEffectiveBool(process.env.INPUT_BUILD_SDK_TARGETS, defaultRunBuildSdkTargets, "build_sdk_targets");
    const runBuildTestApp = parseEffectiveBool(process.env.INPUT_BUILD_TEST_APP, defaultRunBuildTestApp, "build_test_app");
    const runTests = parseEffectiveBool(process.env.INPUT_RUN_TESTS, defaultRunTests, "run_tests");
    const runLintPods = parseEffectiveBool(process.env.INPUT_LINT_PODS, defaultRunLintPods, "lint_pods");

    if (!runBuildSdkTargets && !runBuildTestApp && !runTests && !runLintPods) {
        throw new Error(`SDK Validation requires at least one enabled action (event: ${eventName}).`);
    }

    let effectiveBuildMatrix = runBuildSdkTargets || runBuildTestApp ? defaultBuildMatrix : [];
    let effectiveTestAppMatrix = [];
    let effectiveSdkTestsMatrix = runTests ? defaultSdkTestsMatrix : [];

    const buildMatrixOverrideRaw = (process.env.INPUT_BUILD_MATRIX_OVERRIDE_JSON || "").trim();
    if ((runBuildSdkTargets || runBuildTestApp) && buildMatrixOverrideRaw !== "") {
        effectiveBuildMatrix = parseMatrixOverride(buildMatrixOverrideRaw, "build_matrix_override_json");
    }

    const sdkTestsMatrixOverrideRaw = (process.env.INPUT_SDK_TESTS_MATRIX_OVERRIDE_JSON || "").trim();
    if (runTests && sdkTestsMatrixOverrideRaw !== "") {
        effectiveSdkTestsMatrix = parseMatrixOverride(sdkTestsMatrixOverrideRaw, "sdk_tests_matrix_override_json");
    }

    const getRequiredPrimaryEntry = (matrix, label) => {
        const primaryEntry = matrix.find(
            (entry) => entry.runner === sdkTests.runner && entry.xcode === sdkTests.xcode
        );

        if (!primaryEntry) {
            throw new Error(`${label} must include primary sdk_tests entry '${sdkTests.runner}' + '${sdkTests.xcode}'.`);
        }
        if (primaryEntry.informational) {
            throw new Error(`${label} primary sdk_tests entry '${sdkTests.runner}' + '${sdkTests.xcode}' must have informational=false.`);
        }

        return primaryEntry;
    };

    let primaryBuildEntry = null;

    if (runBuildSdkTargets || runBuildTestApp) {
        primaryBuildEntry = getRequiredPrimaryEntry(effectiveBuildMatrix, "build_matrix");
    }

    if (runBuildTestApp) {
        effectiveTestAppMatrix = [primaryBuildEntry];
    }

    const githubOutput = process.env.GITHUB_OUTPUT;
    if (!githubOutput) {
        throw new Error("GITHUB_OUTPUT is not set.");
    }

    const setOutput = (name, value) => {
        fs.appendFileSync(githubOutput, `${name}=${value}\n`);
    };

    setOutput("run_build_sdk_targets", String(runBuildSdkTargets));
    setOutput("run_build_test_app", String(runBuildTestApp));
    setOutput("run_tests", String(runTests));
    setOutput("run_lint_pods", String(runLintPods));
    setOutput("build_matrix_json", JSON.stringify({ include: effectiveBuildMatrix }));
    setOutput("test_app_matrix_json", JSON.stringify({ include: effectiveTestAppMatrix }));
    setOutput("sdk_tests_matrix_json", JSON.stringify({ include: effectiveSdkTestsMatrix }));
    setOutput("sdk_runner", sdkTests.runner);
    setOutput("sdk_xcode", sdkTests.xcode);
};

try {
    main();
} catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
}
