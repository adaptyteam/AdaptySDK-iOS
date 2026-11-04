# Code

Tests use Apple's `Testing` and `XCUITest` framework. 
Dont't use `XCTest` framework.

## Directory structure

- `Adapty/`, `AdaptyCodable/`, and `AdaptyUIBuilder/` contain tests grouped by product module.
- `Tests.Traits/` contains shared test tags and traits for metadata and reporting, not tests.
- `Tests.Utilities/` contains shared test utilities, not tests.

## Test helpers

- Don't call another suite's helpers or fixtures, don't widen their access (e.g. drop `private`) and don't add tests to another suite's file to reach them.
- Write the helper in your own test file; a copy of an existing one is fine.
- A helper meant to be shared goes to `Tests.Utilities/`.
