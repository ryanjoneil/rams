# RAMS: Quick Start

## Installation

RAMS assumes you have the solver you're using in your `PATH`. The default solver is [GLPK]((https://www.gnu.org/software/glpk/)), but you can also use [CLP](https://www.coin-or.org/Clp/), [CBC](https://www.coin-or.org/Cbc/), [HiGHS](https://highs.dev),
and [SCIP](https://scipopt.org).

First make sure you have the latest RAMS installed.

```
gem install rams
```

Now install GLPK or whatever solver you wish.

### Ubuntu

```
sudo apt-get install glpk-utils
```

### Mac OSX

```
brew install glpk
```

## Basic Modeling

You are now ready to formulate and solve models. Try running a script like this:

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
