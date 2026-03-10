# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Firehose requires Archive::CAR

### Fixed
- While processing lexicons, validation errors fall back to the raw string instead of throwing a fatal exception.

## [1.4] - 2026-03-09

### Added
- Added high-level helpers for...
  - Rrepository management: `create_record`, `delete_record`, `put_record`, and `apply_writes`
  - Direct PDS binary uploads: `upload_blob`
  - Identity resolution: `resolve_did_to_handle`

## [1.3] - 2026-03-08
... [rest of file] ...
