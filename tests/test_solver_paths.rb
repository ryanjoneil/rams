require './lib/rams.rb'
require 'test/unit'

# Test for solver path environment variable customization
class TestSolverPaths < Test::Unit::TestCase
  def setup
    # Clear any existing environment variables
    @old_env_vars = {}
    %w[CBC CLP SCIP CPLEX GLPK HIGHS].each do |solver|
      env_var = "RAMS_SOLVER_PATH_#{solver}"
      @old_env_vars[env_var] = ENV[env_var]
      ENV.delete(env_var)
    end
  end

  def teardown
    # Restore original environment variables
    @old_env_vars.each do |key, value|
      if value
        ENV[key] = value
      else
        ENV.delete(key)
      end
    end
  end

  def test_cbc_default_solver_command
    solver = RAMS::Solvers::CBC.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal 'coin.cbc', command[0]
  end

  def test_cbc_custom_solver_command
    ENV['RAMS_SOLVER_PATH_CBC'] = '/custom/path/to/cbc'
    solver = RAMS::Solvers::CBC.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal '/custom/path/to/cbc', command[0]
  end

  def test_clp_default_solver_command
    solver = RAMS::Solvers::CLP.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal 'clp', command[0]
  end

  def test_clp_custom_solver_command
    ENV['RAMS_SOLVER_PATH_CLP'] = '/custom/path/to/clp'
    solver = RAMS::Solvers::CLP.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal '/custom/path/to/clp', command[0]
  end

  def test_scip_default_solver_command
    solver = RAMS::Solvers::SCIP.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal 'scip', command[0]
  end

  def test_scip_custom_solver_command
    ENV['RAMS_SOLVER_PATH_SCIP'] = '/custom/path/to/scip'
    solver = RAMS::Solvers::SCIP.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal '/custom/path/to/scip', command[0]
  end

  def test_cplex_default_solver_command
    solver = RAMS::Solvers::CPLEX.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal 'cplex', command[0]
  end

  def test_cplex_custom_solver_command
    ENV['RAMS_SOLVER_PATH_CPLEX'] = '/custom/path/to/cplex'
    solver = RAMS::Solvers::CPLEX.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal '/custom/path/to/cplex', command[0]
  end

  def test_glpk_default_solver_command
    solver = RAMS::Solvers::GLPK.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal 'glpsol', command[0]
  end

  def test_glpk_custom_solver_command
    ENV['RAMS_SOLVER_PATH_GLPK'] = '/custom/path/to/glpsol'
    solver = RAMS::Solvers::GLPK.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal '/custom/path/to/glpsol', command[0]
  end

  def test_highs_default_solver_command
    solver = RAMS::Solvers::HiGHS.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal 'highs', command[0]
  end

  def test_highs_custom_solver_command
    ENV['RAMS_SOLVER_PATH_HIGHS'] = '/custom/path/to/highs'
    solver = RAMS::Solvers::HiGHS.new
    command = solver.solver_command('/path/to/model.lp', '/path/to/solution.sol', [])
    assert_equal '/custom/path/to/highs', command[0]
  end
end