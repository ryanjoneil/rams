# Ruby Algebraic Modeling System

RAMS is a library for formulating and solving [Mixed Integer Linear Programs](https://en.wikipedia.org/wiki/Integer_programming) in Ruby. Currently, it only supports the [GNU Linear Programming Kit](https://www.gnu.org/software/glpk/), but more solvers are on the way.

## Quick Start

Make sure you have `glpsol` available on your system. On OSX you can do that with `brew`:

```
brew install glpk
```

On Linux you can `apt-get` or `yum` install the appropriate package. Now install the [RAMS gem](https://github.com/ryanjoneil/rams/releases/download/v0.1/rams-0.1.gem) and run the following:

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

More examples are available [here](https://github.com/ryanjoneil/rams/tree/master/examples). Happy modeling!