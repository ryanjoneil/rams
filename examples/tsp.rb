#!/usr/bin/env ruby

# Rudimentary TSP solver.
# Usage: ./tsp.rb tsp/example.json

require 'json'
require 'set'
require_relative '../lib/rams'

class STSPSolution
  attr_reader :cost, :subtours

  def initialize(cost, subtours)
    @cost = cost
    @subtours = subtours
  end

  def feasible
    subtours.count <= 1
  end
end

class STSPSolver
  # We represent STSP as a lower triangular matrix with the diagonal.
  # Thus the first column and row represent connections to the first node.
  def initialize(json_file)
    @distance = JSON.parse File.read(ARGV.first)
    initialize_model
  end

  def solve
    solution = @model.solve
    return nil if solution.status != :optimal

    subtours = walk_subtours(solution)
    eliminate_subtours(subtours) if subtours.count > 1
    STSPSolution.new(solution.objective, subtours)
  end

  private

  def initialize_model
    @model = RAMS::Model.new
    initialize_variables
    initialize_assignment_relaxation
    initialize_objective
  end

  def initialize_variables
    # Arcs are binary variables connecting each pair of locations.
    @arcs = @distance.map do |row|
      row.map { |_| @model.variable(type: :binary) }
    end
  end

  def initialize_assignment_relaxation
    # Assignment Problem Relaxation: each node connects to two other nodes
    rownums.each do |r|
      @model.constrain(
        (
          (0..(r - 1)).map { |c| @arcs[r][c] } +
          ((r + 1)..rownums.last).map { |c| @arcs[c][r] }
        ).reduce(:+) == 2
      )
    end
  end

  def initialize_objective
    @model.sense = :min
    @model.objective = @arcs.flatten.zip(@distance.flatten).map { |a, d| a * d }.reduce :+
  end

  def rownums
    (0..@distance.size - 1).to_a
  end

  def eliminate_subtours(subtours)
    # Generate subtour elimination constraints. These function by
    # requiring at least two arcs to be active in the cutset connecting
    # the subtour and the rest of the nodes.
    subtours.each do |subtour|
      rest = (Set.new(rownums) - Set.new(subtour)).to_a
      cutset = subtour.product(rest).map { |pair| @arcs[pair.max][pair.min] }
      @model.constrain(cutset.reduce(:+) >= 2)
    end
  end

  def walk_subtours(solution)
    connects = find_connections(solution)

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

  def find_connections(solution)
    arc_range = (0..@arcs.count - 1).to_a

    # Unpack arcs into a connections dictionary
    connects = arc_range.map { |i| [i, Set.new] }.to_h
    arc_range.each do |i|
      # Horizonal row up to node i
      (0..i - 1).each do |j|
        if solution[@arcs[i][j]] > 0.5
          connects[i].add j
          connects[j].add i
        end
      end

      # Vertical column below node i
      (i + 1..@arcs.count - 1).each do |j|
        if solution[@arcs[j][i]] > 0.5
          connects[i].add j
          connects[j].add i
        end
      end
    end

    connects
  end
end

solver = STSPSolver.new ARGV.first
n = 0
while n += 1
  puts '=' * 120
  solution = solver.solve
  break if solution.nil?

  puts "[#{n}] length: #{solution.cost} / subtours: #{solution.subtours.count}"
  puts '-' * 120
  solution.subtours.each { |subtour| puts subtour.to_s }
  puts

  break if solution.feasible
end
