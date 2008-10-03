require File.join(File.dirname(__FILE__),'lib/boot') unless defined?(ActiveRecord)
require 'test/unit'
require 'shoulda'
require 'quietbacktrace'
require 'mocha'
require 'factory_girl'
require 'lib/test_case'
require 'named_scope'

class NamedScope::TestCase
  
  def setup_environment
    setup_database
  end
  
  protected
  
  def setup_database
    ActiveRecord::Base.class_eval do
      silence do
        connection.create_table :employees, :force => true do |t|
          t.column :name,         :string
          t.column :email,        :string
        end
        connection.create_table :reports, :force => true do |t|
          t.column :title,        :string
          t.column :body,         :string
          t.column :employee_id,  :integer
        end
      end
    end
  end
  
end

class Employee < ActiveRecord::Base
  has_many :reports do
    def urgent
      find :all, :conditions => {:title => 'URGENT'}
    end
  end
end

class Report < ActiveRecord::Base
  named_scope :with_urgent_title, :conditions => {:title => 'URGENT'}
  named_scope :with_urgent_body, :conditions => "body LIKE '%URGENT%'"
  belongs_to :employee
  def urgent_title? ; self[:title] == 'URGENT' ; end
  def urgent_body? ; self[:body] =~ /URGENT/ ; end
end



