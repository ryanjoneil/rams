module RAMS
  # A Solution contains the output running a model through a solver:
  #
  #     * Solution status
  #     * Objective value
  #     * Primal variable values
  #     * Dual prices
  #
  class Solution
    attr_reader :status, :objective, :primal, :dual

    def initialize(status, objective, primal, dual)
      @status = status
      @objective = objective
      @primal = primal
      @dual = dual
    end

    def [](variable)
      primal[variable]
    end
  end
end
