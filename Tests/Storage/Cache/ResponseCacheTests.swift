//
//  ResponseCacheTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

import Testing

/// Umbrella suite for all file-cache tests.
///
/// Marked `.serialized` so that tests don't run in parallel: they share
/// `Cache.rootDirectory` (mutable static), and parallel runs would race on
/// global state. Nested suites inherit `.serialized`, so the whole cache
/// test set executes strictly sequentially.
@Suite("ResponseCache", .serialized)
struct ResponseCacheTests {}

#endif
