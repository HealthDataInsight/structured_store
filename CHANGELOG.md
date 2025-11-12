# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-11-12

### Added

- Added tested examples using Binary JSON and non-JSON store columns (vanilla binary and text)
- The Rails JSON Schema validator can now call a lambda schema
- Support for JSON schema properties with `type: "array"` with support for `$ref`, `string`, `integer` and `boolean` items

### Changed

- The structured_store column is now explicitly named to allow for alternative store names and multiple stores per record
- `BlankRefResolver` now handles array types in addition to scalar types
- Refactored resolver constructor interface for cleaner architecture
- Registry methods simplified with cleaner separation of concerns

## [0.1.0]

### Added

- Created a Rails JSON Schema validator to validate JSON attributes
- Added a VersionedSchema model and migration generator to manage schemas
- The Storable concern adds structured store functionality to models with a JSON store column
- RefResolvers registry allows you to resolve custom $ref URIs, enabling composite fields and external lookups
- Example custom lookup resolver included in the test app tests
- New JsonDateRangeResolver for composite date ranges
- Added a SchemaInspector to abstract away schema inspection and validation

[unreleased]: https://github.com/HealthDataInsight/structured_store/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/HealthDataInsight/structured_store/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/HealthDataInsight/structured_store/releases/tag/v0.1.0
