
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__)+'/../debug.log')
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/]
  def execute_with_query_record(sql, name = nil, &block)
    $queries_executed ||= []
    $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
    execute_without_query_record(sql, name, &block)
  end
  alias_method_chain :execute, :query_record
end

module NamedScope
  class TestCase < Test::Unit::TestCase
    
    self.new_backtrace_silencer(:shoulda) { |line| line.include? 'lib/shoulda' }
    self.new_backtrace_silencer(:mocha) { |line| line.include? 'lib/mocha' }
    self.backtrace_silencers << :shoulda << :mocha
    
    def test_truth ; end
    
    protected
    
    def rails_version
      ENV['RAILS_VERSION']
    end
    
    def rails_126?
      rails_version == '1.2.6'
    end
    
    def rails_204?
      rails_version == '2.0.4'
    end
    
    def assert_sql(*patterns_to_match)
      $queries_executed = []
      yield
    ensure
      failed_patterns = []
      patterns_to_match.each do |pattern|
        failed_patterns << pattern unless $queries_executed.any?{ |sql| pattern === sql }
      end
      assert failed_patterns.empty?, "Query pattern(s) #{failed_patterns.map(&:inspect).join(', ')} not found in:\n#{$queries_executed.inspect}"
    end

    def assert_queries(num = 1)
      $queries_executed = []
      yield
    ensure
      assert_equal num, $queries_executed.size, "#{$queries_executed.size} instead of #{num} queries were executed."
    end

    def assert_no_queries(&block)
      assert_queries(0, &block)
    end
    
  end
end
