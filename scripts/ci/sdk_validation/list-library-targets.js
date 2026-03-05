#!/usr/bin/env node

const fs = require("node:fs");
const { execFileSync } = require("node:child_process");

const fail = (message) => {
    console.error(message);
    process.exit(1);
};

const useStdin = process.argv.includes("--stdin");

const readDumpPackage = () => {
    if (useStdin) {
        return fs.readFileSync(0, "utf8");
    }

    try {
        return execFileSync("swift", ["package", "dump-package"], {
            encoding: "utf8",
            maxBuffer: 10 * 1024 * 1024,
        });
    } catch (error) {
        const stderr = error?.stderr?.toString().trim();
        fail(stderr || error.message);
    }
};

const raw = readDumpPackage().trim();
if (raw.length === 0) {
    fail("swift package dump-package produced no output.");
}

let pkg;
try {
    pkg = JSON.parse(raw);
} catch (error) {
    fail(`Failed to parse swift package dump-package output: ${error.message}`);
}

const products = Array.isArray(pkg.products) ? pkg.products : [];
const libraryProducts = products.filter((product) => {
    if (!product || typeof product !== "object" || Array.isArray(product)) return false;
    const type = product.type;
    return Boolean(type && typeof type === "object" && Object.prototype.hasOwnProperty.call(type, "library"));
});

if (libraryProducts.length === 0) {
    fail("No SwiftPM library products found in Package.swift.");
}

const libraryTargets = [
    ...new Set(
        libraryProducts.flatMap((product) => (
            Array.isArray(product.targets) ? product.targets : []
        ))
    ),
];

if (libraryTargets.length === 0) {
    fail("No SwiftPM library targets found in Package.swift products.");
}

for (const target of libraryTargets) {
    console.log(target);
}
