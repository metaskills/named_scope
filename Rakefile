require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

def reset_invoked
  ['test_rails','test'].each do |name|
    Rake::Task[name].instance_variable_set '@already_invoked', false
  end
end


desc 'Default: run unit tests.'
task :default => :test

desc 'Test the NamedScope plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Test the NamedScope plugin with Rails 2.0.4 & 1.2.6 gems.'
task :test_rails do
  test = Rake::Task['test']
  versions = ['2.0.4','1.2.6']
  versions.each do |version|
    ENV['RAILS_VERSION'] = version
    test.invoke
    reset_invoked unless version == versions.last
  end
end

desc 'Generate documentation for the NamedScope plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'NamedScope'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


