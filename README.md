# Ruby Algebraic Modeling System

[![Gem Version](https://badge.fury.io/rb/rams.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/rams)

![RAMS logo](logo.svg)

RAMS is a library for formulating and solving [Mixed Integer Linear Programs][
  milp] in Ruby. Currently it supports the following open source solvers. The
versions listed are the ones RAMS is tested against.

* [CBC][cbc] 2.10.13
* [CLP][clp] 1.17.11
* [GNU Linear Programming Kit][glpk] 5.0
* [HiGHS][highs] 1.16.0
* [SCIP][scip] 10.1.0

RAMS requires Ruby 3.1 or later and is tested on Ruby 4.0.

## Quick start

### Installation

RAMS assumes you have the solver you're using in your `PATH`. The default solver
is HiGHS, but you can easily switch to any of the solvers listed above.

First make sure you have the latest RAMS installed.

```bash
gem install rams
```

Now install HiGHS or whatever solver you wish. The command below works on Fedora
Linux. Consult the solver instructions for installation on your platform.

```bash
sudo dnf install coin-or-HiGHS
```

Fedora's package may lag behind the latest HiGHS release. Prebuilt binaries of
the latest version are available on the [HiGHS releases page][highs-releases].

### A first model

You are now ready to formulate and solve models. Try running a script like this.

```ruby
require 'rams'

m = RAMS::Model.new

x1 = m.variable type: :binary
x2 = m.variable type: :binary
x3 = m.variable type: :binary

m.constrain(x1 + x2 + x3 <= 2)
m.constrain(x2 + x3 <= 1)

m.sense = :max
m.objective = 1 * x1 + 2 * x2 + 3 * x3

solution = m.solve
puts <<-HERE
objective: #{solution.objective}
x1 = #{solution[x1]}
x2 = #{solution[x2]}
x3 = #{solution[x3]}
HERE
```

You should get output along the lines of the following.

```txt
objective: 4.0
x1 = 1.0
x2 = 0.0
x3 = 1.0
```

## Modeling primitives

The first class you need to instantiate is `RAMS::Model`. Everything else is
created by interacting with instances of the `Model` class.

```ruby
require 'rams'

m = RAMS::Model.new
```

### Variables

Variables can be continuous (the default), integer, or binary. They are
associated with an individual model.

```ruby
x1 = m.variable
x2 = m.variable type: :integer
x3 = m.variable type: :binary
```

By default, a continuous variable has a lower bound of `0` and an upper bound of
`nil`, representing positive infinity.

```ruby
puts "#{m.variables.values.map { |x| [x.low, x.high ]}}"
```

```ruby
[[0.0, nil], [0.0, nil], [0.0, nil]]
```

To set a variable's lower bound to negative infinity, pass a `low: inf` keyword
argument to the `Model.variable` method. Similarly, upper bounds can be passed
in to `Model.variable` using the `high` keyword argument.

```ruby
x4 = m.variable(type: :integer, low: nil, high: 10)
```

The binary variables may appear to have an upper bound of positive infinity, but
that becomes `1` when it is written to the solver. To see a model the way it is
passed to a solver, use the `to_lp` method. This returns the model in [LP
format][lp]. Note that the variable names are different in the `to_lp` output.

```ruby
puts m.to_lp
```

```txt
max
  obj: 0 v1
st

bounds
  0.0 <= v1 <= +inf
  0.0 <= v2 <= +inf
  0.0 <= v3 <= 1.0
  -inf <= v4 <= 10
general
  v2
  v4
binary
  v3
end
```

### Constraints

Now we're ready to add some constraints. These can be done using linear
inequalities and the `Model.constrain` method.

```ruby
c1 = m.constrain(2*x1 + x2/2 <= 5)
c2 = m.constrain(x2 + x3 >= 2 - x4)
c3 = m.constrain(x2 == 2*x3)
```

When an inequality is instantiated, all the variables are moved into its `lhs`
attribute, and the constant is stored in its `rhs` attribute. The `sense` of the
inequality is also available.

```ruby
puts <<-HERE
#{c1.lhs[x1]} * x1 + #{c1.lhs[x2]} * x2 #{c1.sense} #{c1.rhs}
#{c2.lhs[x2]} * x2 + #{c2.lhs[x3]} * x3 + #{c2.lhs[x4]} * x4 #{c2.sense} #{c2.rhs}
#{c3.lhs[x2]} * x2 + #{c3.lhs[x3]} #{c3.sense} #{c3.rhs}
HERE
```

```txt
2.0 * x1 + 0.5 * x2 <= 5.0
1.0 * x2 + 1.0 * x3 + 1.0 * x4 >= 2.0
1.0 * x2 + -2.0 == 0.0
```

### Objective functions

The objective sense is available through the `sense` attribute. `:max` is the
default. To minimize, set the sense to `:min`. Similarly, assign to the
`objective` attribute to set the objective function. RAMS defaults to no
objective function, or feasibility models. Explicitly setting the sense is
always a good idea.

```ruby
m.objective = x1 + 2*x2 + 3*x3 - x4
m.sense = :max
```

### Solutions

To get a model solution, simply call `solve`. The `objective`, primal variable
values, and dual prices can be accessed directly off of this object, along with
the solution status.

```ruby
puts <<-HERE
z = #{solution.objective}
x = #{[x1, x2, x3, x4].map { |x| solution[x] }}
y = #{[c1, c2, c3].map { |c| solution.dual[c] }}
HERE
```

```txt
z = 10.0
x = [2.0, 2.0, 1.0, -1.0]
y = [nil, nil, nil]
```

Dual prices are only meaningful for linear programs. This model has integer and
binary variables, so HiGHS doesn't report any and `solution.dual` is empty. For
a model with only continuous variables, `solution.dual` maps each constraint to
its dual price.

## Solver configuration

### Verbosity

If you want to see what the solver is doing, simply set `verbose` to `true` on
the model before solving.

```ruby
m.verbose = true
solution = m.solve
```

This should give you output like the following, depending on your model and
solver. Note that the output is not streamed in real time, but merely printed
after solving.

```txt
Running HiGHS 1.16.0 (git hash: f3f113d): Copyright (c) 2026 under MIT licence terms
Includes third-party software components, see THIRD_PARTY_NOTICES.md for full details
Command line parsed using CLI11 2.5.0: Copyright (c) 2017-2025 University of Cincinnati
Set option solution_file to "/tmp/20261124-1-dwg0ih.lp.sol"
MIP 20261124-1-dwg0ih has 3 rows; 4 cols; 7 nonzeros; 3 integer variables (1 binary)
[...snip...]
```

### Switching solvers

If you want to switch to a different solver, install that solver onto your
system and change the `solver` attribute on your model.

```ruby
m.solver = :cbc   # or
m.solver = :clp   # or
m.solver = :glpk  # or
m.solver = :highs # or
m.solver = :scip
```

## Solver path customization

By default, RAMS assumes that solvers are available in your system's `PATH` with
their standard names. However, you can customize the path or name for any solver
using environment variables.

* `RAMS_SOLVER_PATH_CBC` - Override path for CBC (defaults to `coin.cbc`)
* `RAMS_SOLVER_PATH_CLP` - Override path for CLP (defaults to `clp`)
* `RAMS_SOLVER_PATH_GLPK` - Override path for GLPK (defaults to `glpsol`)
* `RAMS_SOLVER_PATH_HIGHS` - Override path for HiGHS (defaults to `highs`)
* `RAMS_SOLVER_PATH_SCIP` - Override path for SCIP (defaults to `scip`)

For example, if you have GLPK installed in a custom location:

```bash
export RAMS_SOLVER_PATH_GLPK=/opt/glpk/bin/glpsol
```

Or if you have HiGHS installed in a custom location:

```bash
export RAMS_SOLVER_PATH_HIGHS=/opt/highs/bin/highs
```

These environment variables are particularly useful when you have multiple
versions of solvers installed or when solvers are installed in non-standard
locations.

### Solver Arguments

Additional solver arguments can be passed as though they are command line flags.
The following adds both `--dfs` and `--bib` arguments to the GLPK invocation.

```ruby
m.solver = :glpk
m.args = ['--dfs', '--bib']
m.solve
```

```txt
GLPSOL--GLPK LP/MIP Solver 5.0
Parameter(s) specified in the command line:
 --lp /tmp/20261124-1-hc7q01.lp --output /tmp/20261124-1-hc7q01.lp.sol --dfs
 --bib
Reading problem data from '/tmp/20261124-1-hc7q01.lp'...
[...snip...]
```

This can be used to do things like set time limits on finding solutions. For
instance, we can do that with GLPK as follows.

```ruby
m.solver = :glpk
m.args = ['--tmlim', '3']
m.solve
```

For a more interesting example, if you are using SCIP, you can turn off
presolving using the following configuration. This can be useful since SCIP
doesn't provide dual prices for constraints that have been presolved out of the
problem formulation.

```ruby
m.solver = :scip
m.args = ['-c', 'set presolving maxrounds 0']
m.solve
```

Similarly, if you are using HiGHS, you can set a time limit or choose a specific
algorithm.

```ruby
m.solver = :highs
m.args = ['--time_limit', '10', '--solver', 'simplex']
m.solve
```

Every solver has different options, so check the manual to see what command line
flags are available to you.

More modeling examples are available [in the examples folder][examples]. Happy
modeling!

[cbc]: https://www.coin-or.org/Cbc/
[clp]: https://www.coin-or.org/Clp/
[examples]: https://github.com/ryanjoneil/rams/tree/main/examples
[glpk]: https://www.gnu.org/software/glpk/
[highs]: https://highs.dev/
[highs-releases]: https://github.com/ERGO-Code/HiGHS/releases
[lp]: https://lpsolve.sourceforge.net/5.0/CPLEX-format.htm
[milp]: https://en.wikipedia.org/wiki/Integer_programming
[scip]: https://www.scipopt.org/
