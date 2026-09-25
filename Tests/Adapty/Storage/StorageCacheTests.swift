//
//  StorageCacheTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 17.08.2026.
//

import Testing

/// Umbrella suite for all file-cache tests.
///
/// Marked `.serialized` so that tests don't run in parallel: they share
/// `Cache.rootDirectory` (mutable static), and parallel runs would race on
/// global state. Nested suites inherit `.serialized`, so the whole cache
/// test set executes strictly sequentially.
@Suite(
    "StorageCache Tests",
    .serialized,
    .component("StorageCache"),
    .owner("Aleksei Valiano"),
    .risk(.critical),
    .layer(.unit)
)
enum StorageCacheTests {}

