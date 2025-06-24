# Ruby Algebraic Modeling System

![RAMS](logo.svg)

RAMS is a library for formulating and solving [Mixed Integer Linear Programs](https://en.wikipedia.org/wiki/Integer_programming) in Ruby. Currently it supports the following open source solvers.

* [CLP](https://www.coin-or.org/Clp/)
* [CBC](https://www.coin-or.org/Cbc/)
* [GNU Linear Programming Kit](https://www.gnu.org/software/glpk/)
* [HiGHS](https://highs.dev/)
* [SCIP](https://www.scipopt.org/)

## Quick start

### Installation

RAMS assumes you have the solver you're using in your `PATH`. The default solver is [GLPK]((https://www.gnu.org/software/glpk/)), but you can also use [CLP](https://www.coin-or.org/Clp/), [CBC](https://www.coin-or.org/Cbc/), [HiGHS](https://highs.dev),
and [SCIP](https://scipopt.org).

First make sure you have the latest RAMS installed.

```bash
gem install rams
```

Now install GLPK or whatever solver you wish.

#### Fedora

```bash
sudo dnf install glpk-utils
```

#### Ubuntu

```bash
sudo apt-get install glpk-utils
```

#### Mac OSX

```zsh
brew install glpk
```

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

The first class you need to instantiate is `RAMS::Model`. Everything else is created by interacting with instances of the `Model` class.

```ruby
require 'rams'

m = RAMS::Model.new
```

### Variables

Variables can be continuous (the default), integer, or binary. They are associated with an individual model.

```ruby
x1 = m.variable
x2 = m.variable type: :integer
x3 = m.variable type: :binary
```

By default, a continuous variable has a lower bound of `0` and an upper bound of `nil`, representing positive infinity.

```ruby
puts "#{m.variables.values.map { |x| [x.low, x.high ]}}"
```

```ruby
[[0.0, nil], [0.0, nil], [0.0, nil]]
```

To set a variable's lower bound to negative infinity, pass a `low: inf` keyword argument to the `Model.variable` method. Similarly, upper bounds can be passed in to `Model.variable` using the `high` keyword argument.

```ruby
x4 = m.variable(type: :integer, low: nil, high: 10)
```

The binary variables may appear to have an upper bound of positive infinity, but that becomes `1` when it is written to the solver. To see a model the way it is passed to a solver, use the `to_lp` method. This returns the model in [LP format](https://lpsolve.sourceforge.net/5.0/CPLEX-format.htm). Note that the variable names are different in the `to_lp` output.

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

Now we're ready to add some constraints. These can be done using linear inequalities and the `Model.constrain` method.

```ruby
c1 = m.constrain(2*x1 + x2/2 <= 5)
c2 = m.constrain(x2 + x3 >= 2 - x4)
c3 = m.constrain(x2 == 2*x3)
```

When an inequality is instantiated, all the variables are moved into its `lhs` attribute, and the constant is stored in its `rhs` attribute. The `sense` of the inequality is also available.

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

The objective sense is available through the `sense` attribute. `:max` is the default. To minimize, set the sense to `:min`. Similarly, assign to the `objective` attribute to set the objective function. RAMS defaults to no objective function, or feasibility models. Explicitly setting the sense is always a good idea.

```ruby
m.objective = x1 + 2*x2 + 3*x3 - x4
m.sense = :max
```

### Solutions

To get a model solution, simply call `solve`. The `objective`, primal variable values, and dual prices can be accessed directly off of this object, along with the solution status.

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
y = [5.0, 0.0, 0.0]
```

## Solver configuration

### Verbosity

If you want to see what the solver is doing, simply set `verbose` to `true` on the model before solving.

```ruby
m.verbose = true
solution = m.solve
```

This should give you output line the following, depending on your model and solver. Note that the output is not streamed in real time, but merely printed after solving.

```txt
GLPSOL: GLPK LP/MIP Solver, v4.60
Parameter(s) specified in the command line:
 --lp /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-1c6k1bm.lp
 --output /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-1c6k1bm.lp.sol
Reading problem data from '/var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-1c6k1bm.lp'...
[...snip...]
```

### Switching solvers

If you want to switch to a different solver, install that solver onto your system and change the `solver` attribute on your model.

```ruby
m.solver = :cbc   # or
m.solver = :clp   # or
m.solver = :glpk  # or
m.solver = :highs # or
m.solver = :scip
```

## Solver path customization

By default, RAMS assumes that solvers are available in your system's PATH with their standard names. However, you can customize the path or name for any solver using environment variables.

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

These environment variables are particularly useful when you have multiple versions of solvers installed or when solvers are installed in non-standard locations.

### Solver Arguments

Additional solver arguments can be passed as though they are command line flags. The following adds both `--dfs` and `--bib` arguments to the GLPK invocation.

```ruby
m.args = ['--dfs', '--bib']
m.solve
```

```txt
GLPSOL: GLPK LP/MIP Solver, v4.60
Parameter(s) specified in the command line:
 --lp /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-crkxuo.lp
 --output /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-crkxuo.lp.sol
 --dfs --bib
Reading problem data from '/var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-crkxuo.lp'...
[...snip...]
```

This can be used to do things like set time limits on finding solutions. For instance, we can do that with GLPK as follows.

```ruby
m.args = ['--tmlim', '3']
m.solve
```

For a more interesting example, if you are using SCIP, you can turn off presolving using the following configuration. This can be useful since SCIP doesn't provide dual prices for constraints that have been presolved out of the problem formulation.

```ruby
m.solver = :scip
m.args = ['-c', 'set presolving maxrounds 0']
m.solve
```

Similarly, if you are using HiGHS, you can set a time limit or choose a specific algorithm.

```ruby
m.solver = :highs
m.args = ['--time_limit', '10', '--solver', 'simplex']
m.solve
```

Every solver has different options, so check the manual to see what command line flags are available to you.

More modeling examples are available [in the examples folder](<https://github.com/ryanjoneil/rams/tree/master/examples>). Happy modeling!
