require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'tests'
  t.test_files = FileList['tests/test*.rb', 'tests/formatters/test*.rb']
  t.verbose = true
end
