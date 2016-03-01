require_relative 'expression'

module RAMS
  # TODO
  class Variable < Expression
    attr_reader :name

    def initialize(name = '')
      @name = name
      super({ self => 1.0 })
    end

    def to_s
      name.to_s
    end

    def hash
      object_id
    end
  end
end
