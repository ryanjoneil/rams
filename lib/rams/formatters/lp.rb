module RAMS
  module Formatters
    # LP formatter
    class LP
      # rubocop:disable AbcSize
      def self.format(model)
        <<-LP
#{model.sense}
  obj: #{expression model.objective}
st
  #{model.constraints.values.map { |c| constraint c }.join "\n  "}
bounds
  #{model.variables.values.map { |v| bounds v }.join "\n  "}
general
  #{model.variables.values.select { |v| v.type == :integer }.map(&:name).join "\n  "}
binary
  #{model.variables.values.select { |v| v.type == :binary }.map(&:name).join "\n  "}
end
        LP
      end
      # rubocop:enable AbcSize

      def self.expression(expr)
        expr_terms = terms(expr.coefficients)
        expr_terms << constant(expr.constant) unless expr.constant.zero?
        expr_terms.join(' ').sub(/^\+\s*/, '')
      end

      def self.constraint(cons)
        sense_s = cons.sense == :== ? '=' : cons.sense.to_s
        "#{cons.name}: #{terms(cons.lhs).join(' ').sub(/^\+\s*/, '')} #{sense_s} " +
          constant(cons.rhs).sub(/^\+\s*/, '')
      end

      def self.terms(coef)
        coef.map { |v, c| variable(v, c) }
      end

      def self.variable(var, coeff)
        "#{constant(coeff)} #{var.name}"
      end

      def self.constant(const)
        "#{const >= 0 ? '+' : '-'} #{const.abs}"
      end

      def self.bounds(var)
        return bounds_binary(var) if var.type == :binary
        "#{var.low.nil? ? '-inf' : var.low} <= #{var.name} <= #{var.high.nil? ? '+inf' : var.high}"
      end

      def self.bounds_binary(var)
        low_s = var.low.nil? ? 0.0 : [0.0, var.low].max
        high_s = var.high.nil? ? 1.0 : [1.0, var.high].min
        "#{low_s} <= #{var.name} <= #{high_s}"
      end
    end
  end
end
