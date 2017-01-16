# Ruby Algebraic Modeling System

RAMS is a library for formulating and solving [Mixed Integer Linear Programs](https://en.wikipedia.org/wiki/Integer_programming) in Ruby. Currently it supports the following solvers:

* [CLP](https://www.coin-or.org/Clp/)
* [CBC](https://www.coin-or.org/Cbc/)
* [CPLEX](https://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/)
* [GNU Linear Programming Kit](https://www.gnu.org/software/glpk/)
* [SCIP](http://scip.zib.de)

## Quick Start

GLPK is the default solver, so make sure you at least have `glpsol` available on your system. On OSX you can do that with `brew`:

```
brew install glpk
```

On Linux you can `apt-get` or `yum` install the appropriate package. Now you can install the RAMS gem.

```
gem install rams
```

You should have everything installed to build and solve models now. Try running something like this:

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

You should get output along the lines of the following:

```
objective: 4.0
x1 = 1.0
x2 = 0.0
x3 = 1.0
```

If you want to switch to a different solver, simply install that solver onto your system, and change the `solver` attribute on the model. Make sure you have that solver's executable in your `PATH`.

```ruby
m.solver = :cbc   # or
m.solver = :clp   # or
m.solver = :cplex # or
m.solver = :glpk  # or
m.solver = :scip
```

Additional solver arguments can be passed as though they are command line flags.

```ruby
m.args = ['--dfs', '--bib']
```

More examples are available [here](https://github.com/ryanjoneil/rams/tree/master/examples). Happy modeling!
