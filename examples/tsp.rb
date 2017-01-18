#!/usr/bin/env ruby

# Rudimentary TSP solver.
# Usage: ./tsp.rb tsp/example.json

require 'json'
require 'set'
require_relative '../lib/rams'

def walk_subtours(arcs, solution)
  arc_range = (0..arcs.count - 1).to_a

  # Unpack arcs into a connections dictionary
  connects = arc_range.map { |i| [i, Set.new] }.to_h
  arc_range.each do |i|
    # Horizonal row up to node i
    (0..i - 1).each do |j|
      if solution[arcs[i][j]] > 0.5
        connects[i].add j
        connects[j].add i
      end
    end

    # Vertical column below node i
    (i + 1..arcs.count - 1).each do |j|
      if solution[arcs[j][i]] > 0.5
        connects[i].add j
        connects[j].add i
      end
    end
  end

  # Identify subtours
  subtours = []
  unseen = Set.new connects.keys

  # Pick an arbitrary node to start at
  current = unseen.first
  unseen.delete current

  tour = [current]
  until unseen.empty?
    # Continue down an arbitrary path
    current = connects[current].find { |n| unseen.include? n }

    if current.nil?
      # This subtour is done
      current = unseen.first unless unseen.empty?
      subtours << tour
      tour = [current]
    else
      tour << current
    end

    unseen.delete current
  end

  subtours << tour unless tour.empty?
  subtours
end

# We represent STSP as a lower triangular matrix with the diagonal.
# Thus the first column and row represent connections to the first node.
distance = JSON.parse File.read(ARGV.first)

m = RAMS::Model.new

# Arcs are binary variables connecting each pair of locations.
arcs = distance.map do |row|
  row.map { |_| m.variable(type: :binary) }
end

# Assignment Problem Relaxation: each node connects to two other nodes
rownums = (0..distance.size - 1).to_a
rownums.each do |r|
  m.constrain(
    (
      (0..(r - 1)).map { |c| arcs[r][c] } +
      ((r + 1)..rownums.last).map { |c| arcs[c][r] }
    ).reduce(:+) == 2
  )
end

# Our formulation thus far only represents a combinatorial relaxation of
# STSP as an assignment problem.  It is possible the solver will return
# disconnected subtours.
m.sense = :min
m.objective = arcs.flatten.zip(distance.flatten).map { |a, d| a * d }.reduce :+

n = 0
while n += 1
  solution = m.solve

  puts '=' * 120
  if solution.status != :optimal
    puts "invalid solution status: #{solution.status}"
    break
  end

  subtours = walk_subtours(arcs, solution)

  puts "[#{n}] length: #{solution.objective} / subtours: #{subtours.count}"
  puts '-' * 120
  subtours.each { |subtour| puts subtour.to_s }
  puts

  break if subtours.count <= 1

  # Generate subtour elimination constraints.  These function by
  # adding a knapsack constraint setting the sum of the arcs
  # in each subtour to their cardinality minus one.
  subtours.each do |subtour|
    # n points in a tour have n arcs, not n-1.  That means we
    # have to include the arc going back to the start node.
    pairs = subtour[0, subtour.count].zip(subtour[1, subtour.count] + [subtour.first])
    m.constrain(
      # Column # is the higher of the two
      pairs.map { |p| arcs[p.max][p.min] }.reduce(:+) <= (pairs.count - 1)
    )
  end
end
