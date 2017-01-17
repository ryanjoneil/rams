#!/usr/bin/env ruby

require_relative '../lib/rams'

# Generic formulation for the Capacitated Facility Location Problem
# This example was converted from the ZIMPL examples.

FACILITIES = (:A..:D).to_a
CUSTOMERS  = (1..9).to_a

# Costs for opening a facility
FIXED_COST = {A: 500, B: 600, C: 700, D: 800}

# Capacity of a facility at each site
CAPACITY = {A: 40, B: 55, C: 73, D: 90}

# Demand from each customer
DEMAND = {1 => 10, 2 => 14, 3 => 17, 4 => 8, 5 => 9, 6 => 12, 7 => 11, 8 => 15, 9 => 16}

# Transportation cost from each facility to each customer
TRANSPORTATION = {
  A: {1 => 55, 2 =>  4, 3 => 17, 4 => 33, 5 => 47, 6 => 98, 7 => 19, 8 => 10, 9 =>  6},
  B: {1 => 42, 2 => 12, 3 =>  4, 4 => 23, 5 => 16, 6 => 78, 7 => 47, 8 =>  9, 9 => 82},
  C: {1 => 17, 2 => 34, 3 => 65, 4 => 25, 5 =>  7, 6 => 67, 7 => 45, 8 => 13, 9 => 54},
  D: {1 => 60, 2 =>  8, 3 => 79, 4 => 24, 5 => 28, 6 => 19, 7 => 62, 8 => 18, 9 => 45}
}

m = RAMS::Model.new

# Fixed cost variables for opening facilities
y = FACILITIES.map { |f| [f, m.variable(type: :binary)] }.to_h

# Variables to represent facility/customer relations
x = FACILITIES.product(CUSTOMERS).map do |f, c|
  [[f, c], m.variable(type: :binary)]
end.to_h

# Supply each customer from one facility
CUSTOMERS.each do |c|
  m.constrain(FACILITIES.map { |f| x[[f, c]] }.reduce(:+) == 1)
end

# Using a facility incurs its fixed cost
FACILITIES.product(CUSTOMERS).map do |f, c|
  m.constrain(x[[f, c]] <= y[f])
end

# Facilities cannot exceed their capacities
FACILITIES.each do |f|
  m.constrain(CUSTOMERS.map { |c| DEMAND[c] * x[[f, c]] }.reduce(:+) <= CAPACITY[f])
end

# Minimize overall cost
m.sense = :min
m.objective = FACILITIES.map { |f| FIXED_COST[f] * y[f] }.reduce(:+) +
  FACILITIES.product(CUSTOMERS).map { |f, c| TRANSPORTATION[f][c] * x[[f, c]] }.reduce(:+)

solution = m.solve

puts "status: #{solution.status}"
puts "total cost: #{solution.objective}"
FACILITIES.each do |f|
  next unless solution[y[f]] > 0.5
  puts "facility #{f}: #{CUSTOMERS.select { |c| solution[x[[f, c]]] > 0.5 }}"
end

