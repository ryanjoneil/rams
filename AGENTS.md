# AGENTS.md

Notes for anyone, human or agent, working on RAMS (Ruby Algebraic Modeling
System). User-facing documentation lives in `README.md`; this file covers how
the project works and what to watch out for when changing it.

## What RAMS is

A small Ruby gem for formulating mixed integer linear programs and solving them
with open source solvers. It has no runtime dependencies. Every solver is
driven the same way: RAMS writes the model to a temporary LP file, runs the
solver's command-line program on it, and parses the solver's output or
solution file.

## Layout

- `lib/rams/model.rb`: `RAMS::Model`, the entry point. Holds variables,
  constraints, objective, sense, solver choice, `args` and `verbose`.
  `Model::SOLVERS` maps solver symbols to solver instances.
- `lib/rams/{variable,constraint,expression,numeric}.rb`: the modeling
  primitives. Variable names (`v1`, `v2`, ...) come from a global counter, so
  they keep increasing across models in one process.
- `lib/rams/formatters/lp.rb`: writes models in LP format.
- `lib/rams/solvers/solver.rb`: the base class. It writes the LP file, runs the
  command with `Open3`, raises if the exit code isn't 0, and builds a
  `RAMS::Solution`.
- `lib/rams/solvers/{cbc,clp,glpk,highs,scip}.rb`: one subclass per solver.
- `tests/`: test-unit tests, run by `rake test`.
- `examples/`: runnable example models.

## Adding or changing a solver

A solver subclass implements `solver_command(model_path, solution_path, args)`
plus `parse_status`, `parse_objective`, `parse_primal` and `parse_dual`.
Override `solve_and_parse` if the solver prints its solution instead of writing
a file, as SCIP does. Look up the executable with
`solver_executable(default_name, solver_name)` so the
`RAMS_SOLVER_PATH_<NAME>` override works.

A new solver also needs:

- a `require_relative` and an entry in `Model::SOLVERS` in `lib/rams/model.rb`;
- default and override tests in `tests/test_solver_paths.rb`;
- `RAMS_TEST_<NAME>` cases in `tests/test_model.rb`;
- installation in `.github/workflows/test.yml`;
- updates to the README's solver list, `m.solver =` list and
  solver path list.

Only solvers with a freely installable CLI fit this design. Gurobi, CPLEX and
Xpress were investigated for v0.3 and dropped: their free community editions
are Python packages without the command-line program.

## Testing

```bash
bundle install
bundle exec rake test
```

Solver tests only run for solvers whose `RAMS_TEST_<NAME>` variable is set
(`CBC`, `CLP`, `GLPK`, `HIGHS`, `SCIP`). Any value turns a solver on, even an
empty string or `false`, so unset the variable to turn it off. With none set,
only the solver-independent tests run. Set all five to test everything. CI
does.

Default executable names are `coin.cbc`, `clp`, `glpsol`, `highs` and
`scip`. Distributions differ: Fedora ships CBC as `coin.cbc`, but many systems
call it `cbc`. Point RAMS at a different name or path with
`RAMS_SOLVER_PATH_<NAME>`, for example `RAMS_SOLVER_PATH_CBC=cbc`.

To reproduce CI locally, run the suite in a `fedora:45` container with
`ruby rubygem-bundler coin-or-Cbc coin-or-Clp coin-or-HiGHS glpk-utils scip`
installed from dnf. CI replaces Fedora's HiGHS with the upstream build (see
below).

## CI

`.github/workflows/test.yml` runs every push to `main` and every pull request,
whatever its base branch, so stacked PRs get CI. It runs in a `fedora:45`
container, which provides Ruby 4.0 and all solvers except HiGHS.

HiGHS comes from the official static Linux build on GitHub, because Fedora lags
behind. To change its version, update both `HIGHS_VERSION` and the literal
SHA-256 in the solver step. A checksum mismatch fails the job on purpose.

## Ruby and dependencies

- `rams.gemspec` requires Ruby `>= 3.1.0`. CI tests only Ruby 4.0, the version
  in `.ruby-version`.
- `Gemfile.lock` is pinned to bundler 4.0.20, Fedora 45's `rubygem-bundler`.
  Keep it matched to Fedora's bundler, because a different version makes CI
  download and switch bundlers. Don't install bundler 2.x on Ruby 4: it floods
  the log with `already initialized constant Gem::Platform::*` warnings.
- The gem ships only `lib/**`, so the Gemfile, lockfile and tests never reach
  users. Avoid adding runtime dependencies.

## Solver behavior to know about

- **Dual prices are only meaningful for LPs.** For models with integer or
  binary variables, HiGHS reports none, so `solution.dual` is empty. GLPK,
  SCIP and CLP do return values for MIPs, but they aren't LP duals.
- **SCIP doesn't report duals for constraints removed in presolve.**
  `args = ['-c', 'set presolving maxrounds 0']` turns presolve off.
- **Output is printed after solving, not streamed,** when `verbose` is true.
- **HiGHS writes `HiGHS.log` into the working directory.** It's in
  `.gitignore`.

## Documentation

- README code blocks are meant to run in order, exactly as printed, and
  produce the output shown. After changing them, run them and paste the real
  output.
- Keep the README's tested solver versions in step with CI.
- Record user-visible changes in `CHANGELOG.md` under the upcoming version.

## Releasing

Releases are published by hand:

1. Bump `spec.version` in `rams.gemspec`.
2. Date the version's section in `CHANGELOG.md`.
3. Merge to `main`.
4. From an up-to-date `main`, run `gem build rams.gemspec`, then
   `gem push rams-<version>.gem`.
5. Tag and push it: `git tag v<version> && git push origin v<version>`.
6. Create the GitHub release from that tag, using the changelog section as
   notes.

Tags look like `v0.2.0`. Version 0.2.1 was published without a tag.
