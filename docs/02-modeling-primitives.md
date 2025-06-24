# RAMS: Modeling Primitives

The first class you need to instantiate is `RAMS::Model`. Everything else is created by interacting with instances of the `Model` class.

```ruby
require 'rams'

m = RAMS::Model.new
```

## Variables

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

```
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

```
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

## Constraints

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

```
2.0 * x1 + 0.5 * x2 <= 5.0
1.0 * x2 + 1.0 * x3 + 1.0 * x4 >= 2.0
1.0 * x2 + -2.0 == 0.0
```

## Objective Functions

The objective sense is available through the `sense` attribute. `:max` is the default. To minimize, set the sense to `:min`. Similarly, assign to the `objective` attribute to set the objective function. RAMS defaults to no objective function, or feasibility models. Explicitly setting the sense is always a good idea.

```ruby
m.objective = x1 + 2*x2 + 3*x3 - x4
m.sense = :max
```

## Solutions

To get a model solution, simply call `solve`. The `objective`, primal variable values, and dual prices can be accessed directly off of this object, along with the solution status.

```ruby
puts <<-HERE
z = #{solution.objective}
x = #{[x1, x2, x3, x4].map { |x| solution[x] }}
y = #{[c1, c2, c3].map { |c| solution.dual[c] }}
HERE
```

```
z = 10.0
x = [2.0, 2.0, 1.0, -1.0]
y = [5.0, 0.0, 0.0]
```
