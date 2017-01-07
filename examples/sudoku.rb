#!/usr/bin/env ruby

require_relative '../lib/rams'

# 0 indicates a cell value is not given
problem = [
    [0, 0, 0,   6, 9, 2,   0, 4, 0],
    [7, 0, 0,   0, 0, 0,   8, 9, 0],
    [0, 0, 0,   0, 0, 0,   0, 0, 6],

    [0, 0, 9,   0, 1, 7,   0, 0, 3],
    [0, 0, 7,   0, 8, 0,   5, 0, 0],
    [8, 0, 0,   4, 6, 0,   1, 0, 0],

    [5, 0, 0,   0, 0, 0,   0, 0, 0],
    [0, 8, 6,   0, 0, 0,   0, 0, 1],
    [0, 3, 0,   7, 2, 8,   0, 0, 0]
]

# Indexes for creating variables and constraints
rows = (0..(problem.size - 1)).to_a
cols = rows
vals = (1..9).to_a
groups = [0, 3, 6]

# 9x9x9 structure for storing all binary variables
# If x[[r, c, v]] == 1, then problem[r][c] == k.
m = RAMS::Model.new
x = rows.map do |r|
  cols.map do |c|
    vals.map do |v|
      low = problem[c][r] == v ? 1 : 0
      [[r, c, v], m.variable(type: :binary, low: low)]
    end
  end
end.flatten(2).to_h

# Each cell takes on exactly one value
rows.product(cols).each do |r, c|
  m.constrain(vals.map { |v| x[[r, c, v]] }.reduce(:+) == 1)
end

# Each value occurs in each row once
rows.product(vals).each do |r, v|
  m.constrain(cols.map { |c| x[[r, c, v]] }.reduce(:+) == 1)
end

# Each value occurs in each column once
cols.product(vals).each do |c, v|
  m.constrain(rows.map { |r| x[[r, c, v]] }.reduce(:+) == 1)
end

# Each 3x3 group has all unique values
groups.product(groups).each do |p, q|
  vals.each do |v|
    vars = (p..(p + 2)).map do |r|
      ((q..(q + 2))).map do |c|
        x[[r, c, v]]
      end
    end.flatten

    m.constrain(vars.reduce(:+) == 1)
  end
end

# Find a feasible solution
solution = m.solve

# Convert solution values to a nice solution matrix
rows.product(cols).each do |r, c|
  vals.each do |v|
    problem[r][c] = v if solution[x[[r, c, v]]] > 0.5
  end
end

problem.each { |row| puts row.join(' ') }
