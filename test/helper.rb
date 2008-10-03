require File.join(File.dirname(__FILE__),'lib/boot') unless defined?(ActiveRecord)
require 'test/unit'
require 'shoulda'
require 'quietbacktrace'
require 'mocha'
require 'factory_girl'
require 'lib/test_case'
require 'named_scope'

class GroupedScope::TestCase
  
  def setup_environment
    setup_database
    Department.create! :name => 'IT'
    Department.create! :name => 'Human Resources'
    Department.create! :name => 'Finance'
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
        connection.create_table :departments, :force => true do |t|
          t.column :name,         :string
        end
        connection.create_table :department_memberships, :force => true do |t|
          t.column :employee_id,    :integer
          t.column :department_id,  :integer
          t.column :meta_info,      :string
        end
      end
    end
  end
  
end

class Employee < ActiveRecord::Base
  has_many :reports do ; def urgent ; find(:all,:conditions => {:title => 'URGENT'}) ; end ; end
  has_many :taxonomies, :as => :classable
  has_many :department_memberships
  has_many :departments, :through => :department_memberships
  grouped_scope :reports, :departments
end

class Report < ActiveRecord::Base
  named_scope :with_urgent_title, :conditions => {:title => 'URGENT'}
  named_scope :with_urgent_body, :conditions => "body LIKE '%URGENT%'"
  belongs_to :employee
  def urgent_title? ; self[:title] == 'URGENT' ; end
  def urgent_body? ; self[:body] =~ /URGENT/ ; end
end

class Department < ActiveRecord::Base
  named_scope :it, :conditions => {:name => 'IT'}
  named_scope :hr, :conditions => {:name => 'Human Resources'}
  named_scope :finance, :conditions => {:name => 'Finance'}
  has_many :department_memberships
  has_many :employees, :through => :department_memberships
end

class DepartmentMembership < ActiveRecord::Base
  belongs_to :employee
  belongs_to :department
end
