# RAMS: Solver Configuration

## Verbosity

If you want to see what the solver is doing, simply set `verbose` to `true` on the model before solving.

```ruby
m.verbose = true
solution = m.solve
```

This should give you output line the following, depending on your model and solver. Note that the output is not streamed in real time, but merely printed after solving.

```
GLPSOL: GLPK LP/MIP Solver, v4.60
Parameter(s) specified in the command line:
 --lp /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-1c6k1bm.lp
 --output /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-1c6k1bm.lp.sol
Reading problem data from '/var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-1c6k1bm.lp'...
[...snip...]
```

## Switching Solvers

If you want to switch to a different solver, install that solver onto your system and change the `solver` attribute on your model.

```ruby
m.solver = :cbc   # or
m.solver = :clp   # or
m.solver = :cplex # or
m.solver = :glpk  # or
m.solver = :scip
```

## Solver Arguments

Additional solver arguments can be passed as though they are command line flags. The following adds both `--dfs` and `--bib` arguments to the GLPK invocation.

```ruby
m.args = ['--dfs', '--bib']
m.solve
```
```
GLPSOL: GLPK LP/MIP Solver, v4.60
Parameter(s) specified in the command line:
 --lp /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-crkxuo.lp
 --output /var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-crkxuo.lp.sol
 --dfs --bib
Reading problem data from '/var/folders/vj/t2g113b97mq1qzscqh7b8npc0000gn/T/20170126-46037-crkxuo.lp'...
[...snip...]
```

This can be used to do things like set time limits on finding solutions. For instance, we can do that with GLPK as follows:

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

Every solver has different options, so check the manual to see what command line flags are available to you.
