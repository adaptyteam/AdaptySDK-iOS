const { execFileSync } = require("node:child_process");
const fs = require("node:fs");

class ConfigError extends Error {
    constructor(message) {
        super(message);
        this.name = "ConfigError";
    }
}

const fail = (message) => {
    throw new ConfigError(message);
};

const readRequiredFile = (filePath, label = filePath) => {
    try {
        return fs.readFileSync(filePath, "utf8");
    } catch (error) {
        fail(`Unable to read ${label}: ${error.message}`);
    }
};

const parseJson = (raw, label) => {
    try {
        return JSON.parse(raw);
    } catch (error) {
        fail(`Invalid ${label}: ${error.message}`);
    }
};

const parseBool = (raw, defaultValue, label) => {
    const normalized = (raw ?? "").toString().trim().toLowerCase();

    if (normalized === "") return defaultValue;
    if (normalized === "true") return true;
    if (normalized === "false") return false;

    fail(`${label} must be 'true' or 'false'. Got: ${raw}`);
};

const validateBoolean = (value, label) => {
    if (typeof value !== "boolean") {
        fail(`${label} must be a boolean.`);
    }

    return value;
};

const validateMatrix = (matrix, label) => {
    if (!Array.isArray(matrix) || matrix.length === 0) {
        fail(`${label} must be a non-empty JSON array.`);
    }

    const seenRunnerXcode = new Set();

    return matrix.map((entry, index) => {
        if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
            fail(`${label}[${index}] must be an object.`);
        }

        const { runner, xcode, informational } = entry;

        if (typeof runner !== "string" || runner.trim() === "") {
            fail(`${label}[${index}].runner must be a non-empty string.`);
        }
        if (typeof xcode !== "string" || xcode.trim() === "") {
            fail(`${label}[${index}].xcode must be a non-empty string.`);
        }
        if (typeof informational !== "boolean") {
            fail(`${label}[${index}].informational must be a boolean.`);
        }

        const normalizedRunner = runner.trim();
        const normalizedXcode = xcode.trim();
        const uniqueKey = `${normalizedRunner}::${normalizedXcode}`;

        if (seenRunnerXcode.has(uniqueKey)) {
            fail(`${label} contains duplicate runner+xcode pair '${normalizedRunner}' + '${normalizedXcode}'.`);
        }

        seenRunnerXcode.add(uniqueKey);

        return {
            runner: normalizedRunner,
            xcode: normalizedXcode,
            informational,
        };
    });
};

const validateSdkTests = (config) => {
    if (!config || typeof config !== "object" || Array.isArray(config)) {
        fail("sdk_tests must be an object.");
    }

    const { runner, xcode } = config;

    if (typeof runner !== "string" || runner.trim() === "") {
        fail("sdk_tests.runner must be a non-empty string.");
    }
    if (typeof xcode !== "string" || xcode.trim() === "") {
        fail("sdk_tests.xcode must be a non-empty string.");
    }

    return {
        runner: runner.trim(),
        xcode: xcode.trim(),
    };
};

const parseMatrixOverride = (raw, label) => {
    let parsed = parseJson(raw, label);

    if (!Array.isArray(parsed)) {
        if (parsed && typeof parsed === "object" && Array.isArray(parsed.include)) {
            parsed = parsed.include;
        } else {
            fail(`${label} must be a JSON array or an object with include[] array.`);
        }
    }

    return validateMatrix(parsed, label);
};

const workflowDispatchInputsCache = new Map();

const readWorkflowDispatchInputs = (workflowPath) => {
    if (workflowDispatchInputsCache.has(workflowPath)) {
        return workflowDispatchInputsCache.get(workflowPath);
    }

    const rubyScript = `
require "json"
require "yaml"

workflow = YAML.load_file(ARGV[0])
on_section = workflow["on"] || workflow[true]
raise "Missing 'on' section." unless on_section.is_a?(Hash)

workflow_dispatch = on_section["workflow_dispatch"]
raise "Missing 'workflow_dispatch' section." unless workflow_dispatch.is_a?(Hash)

inputs = workflow_dispatch["inputs"]
raise "'workflow_dispatch.inputs' must be a mapping." unless inputs.is_a?(Hash)

defaults = {}
inputs.each do |name, config|
  defaults[name.to_s] = config.is_a?(Hash) ? config["default"] : nil
end

puts JSON.generate(defaults)
`;

    let output;

    try {
        output = execFileSync("ruby", ["-e", rubyScript, workflowPath], {
            encoding: "utf8",
            stdio: ["ignore", "pipe", "pipe"],
        });
    } catch (error) {
        const stderr = error && error.stderr ? error.stderr.toString().trim() : "";
        fail(`Unable to parse ${workflowPath}: ${stderr || error.message}`);
    }

    const parsed = parseJson(output, `${workflowPath} workflow_dispatch inputs`);
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
        fail(`${workflowPath} workflow_dispatch inputs must parse to an object.`);
    }

    workflowDispatchInputsCache.set(workflowPath, parsed);

    return parsed;
};

const readWorkflowBooleanInputDefault = (workflowPath, inputName) => {
    const workflowInputs = readWorkflowDispatchInputs(workflowPath);

    if (!Object.prototype.hasOwnProperty.call(workflowInputs, inputName)) {
        fail(`Unable to locate workflow_dispatch input '${inputName}'.`);
    }

    return validateBoolean(
        workflowInputs[inputName],
        `workflow_dispatch input '${inputName}' default`
    );
};

module.exports = {
    ConfigError,
    fail,
    parseBool,
    parseJson,
    parseMatrixOverride,
    readRequiredFile,
    readWorkflowBooleanInputDefault,
    validateBoolean,
    validateMatrix,
    validateSdkTests,
};
