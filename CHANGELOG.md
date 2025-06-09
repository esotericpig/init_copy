# Changelog | InitCopy

- [Keep a Changelog](https://keepachangelog.com/en/1.1.0)
- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]

## [0.3.0] - 2025-06-09
### Changed
- Major change (again) to remove including `InitCopy`.
  - Instead, include `InitCopy::Able` (was named `InitCopy::Copyable`).
  - This change was made because `include InitCopy` added the `VERSION` const to classes, and it also added two modules to your hierarchy instead of just one: `InitCopy` and `InitCopy::Copyable`. Due to this, I decided only `InitCopy::Able` is better, even though `include InitCopy` was nicer looking and easier to remember.
- Converted Minitest unit tests to spec-style tests.
- Reverted min required Ruby version from `3.0` back to `2.4` because the Gem is quite simple and can be used safely with legacy code.
  - Also added CI test for v2.4.

## [0.2.0] - 2025-06-05
### Changed
- Major change to simplify usage.
  - Must include `InitCopy` in your class/module, override `init_copy(orig)`, and use `ic_copy(var)` instead of clone/dup.
  - Renamed `safe_copy(var)` to `ic_copy?(var)`. (Most users will probably not use this method anyway.)
- Refactored unit tests to reflect new changes.
- Changed doc from `yard` to `rdoc`.
- Renamed git branch `master` to `main`.

### Removed
- Major change to drop support for `Copier`/`Copyer`, which relied on `caller`.
- Dropped `Copiable` alias.

### Fixed
- Applied new RuboCop suggestions for Gemspec, Gemfile, code, etc.

## [0.1.2] - 2021-06-18
### Changed
- Formatted code with RuboCop.

## [0.1.1] - 2020-03-07
### Fixed
- Added `initialize` to the mixin (Copyable) to define a default value to `@init_copy_method_name` so not `nil`.
  - This wasn't necessary, but added Justin Case.

## [0.1.0] - 2020-03-06
Initial release.
