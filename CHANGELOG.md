# Changelog

All notable changes to RAMS are recorded here. Versions follow [Semantic
Versioning](https://semver.org/).

## [0.3.0] - Unreleased

### Changed

- Tested on Ruby 4.0 and Fedora 45. Ruby 3.1 and later is still supported.
- Tested against the latest solver releases: CBC 2.10.13, CLP 1.17.11,
  GLPK 5.0, HiGHS 1.16.0 and SCIP 10.1.0.
- Documentation updates: tested solver versions, the correct Fedora package
  name for HiGHS (`coin-or-HiGHS`), and regenerated sample output.

### Fixed

- README examples now run as printed. The solutions example never called
  `solve`, and the text said `low: inf` where the code uses `low: nil`.

## [0.2.1] - 2026-11-24

### Removed

- The unused `nokogiri` development dependency, which resolves the open
  Dependabot security alerts against it.

## [0.2.0] - 2025-06-24

### Changed

- HiGHS is the default solver.
- Documentation updates and a new logo.

## [0.1.8] - 2025-06-24

### Added

- Support for the HiGHS solver.
- `RAMS_SOLVER_PATH_*` environment variables to override solver executable
  paths.

### Removed

- Support for CPLEX.

## [0.1.7] - 2025-06-24

### Changed

- Requires Ruby 3.1 or later. Dependencies and solvers upgraded to their
  latest stable versions.

## [0.1.6] - 2017-02-05

### Changed

- Requires Ruby 2.4.0.

### Fixed

- Deprecation warnings about `Fixnum`.

## [0.1.5] - 2017-01-26

### Added

- Documentation and more examples.
- `Model#to_lp`, which returns a model in LP format.

## [0.1.4] - 2017-01-17

### Added

- Facility location example.

### Fixed

- Constraints of the form `x <= y`.

## [0.1.3] - 2017-01-16

### Added

- Support for SCIP.

## [0.1.2] - 2017-01-10

### Added

- Support for CPLEX.

## [0.1.1] - 2017-01-08

### Added

- Support for CBC and CLP.

## [0.1] - 2017-01-07

### Added

- Initial release, supporting basic MILP models and the GLPK solver.

[0.3.0]: https://github.com/ryanjoneil/rams/compare/v0.2.0...main
[0.2.1]: https://github.com/ryanjoneil/rams/compare/v0.2.0...d2dc7e9
[0.2.0]: https://github.com/ryanjoneil/rams/compare/v0.1.8...v0.2.0
[0.1.8]: https://github.com/ryanjoneil/rams/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/ryanjoneil/rams/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/ryanjoneil/rams/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/ryanjoneil/rams/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/ryanjoneil/rams/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/ryanjoneil/rams/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/ryanjoneil/rams/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/ryanjoneil/rams/compare/v0.1...v0.1.1
[0.1]: https://github.com/ryanjoneil/rams/releases/tag/v0.1
