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
        connection.create_table :authors, :force => true do |t|
          t.column :name,                     :string, :null => false
          t.column :author_address_id,        :integer
          t.column :author_address_extra_id,  :integer
        end
        connection.create_table :topics, :force => true do |t|
          t.column :title,                  :string
          t.column :author_name,            :string
          t.column :author_email_address,   :string
          t.column :written_on,             :datetime
          t.column :bonus_time,             :time
          t.column :last_read,              :date
          t.column :content,                :text
          t.column :approved,               :boolean, :default => true
          t.column :replies_count,          :integer, :default => 0
          t.column :parent_id,              :integer
          t.column :type,                   :string
        end
        connection.create_table :posts, :force => true do |t|
          t.column :author_id,      :integer
          t.column :title,          :string, :null => false
          t.column :body,           :text, :null => false
          t.column :type,           :string
          t.column :comments_count, :integer, :default => 0
          t.column :taggings_count, :integer, :default => 0
        end
        connection.create_table :author_addresses, :force => true do |t|
        end
        connection.create_table :comments, :force => true do |t|
          t.column :post_id,  :integer
          t.column :body,     :text, :null => false
          t.column :type,     :string
        end
      end
    end
  end
  
end

class Author < ActiveRecord::Base
  has_many    :posts
  has_many    :comments, :through => :posts
  named_scope :davids, :conditions => {:name => 'David'}
end

class Post < ActiveRecord::Base
  named_scope :containing_the_letter_a, :conditions => "body LIKE '%a%'"
  named_scope :with_authors_at_address, lambda { |address| {
      :conditions => [ 'authors.author_address_id = ?', address.id ],
      :joins => 'JOIN authors ON authors.id = posts.author_id'
    }
  }
  belongs_to  :author
  has_many    :comments, :order => 'body'
end

class Topic < ActiveRecord::Base
  named_scope :base
  named_scope :approved, :conditions => {:approved => true}
  named_scope 'approved_as_string', :conditions => {:approved => true}
  named_scope :replied, :conditions => ['replies_count > 0']
  named_scope :written_before, lambda { |time| {:conditions => ['written_on < ?', time]} }
  named_scope :anonymous_extension do
    def one ; 1 ; end
  end
  module NamedExtension
    def two ; 2 ; end
  end
  module MultipleExtensionOne
    def extension_one ; 1 ; end
  end
  module MultipleExtensionTwo
    def extension_two ; 2 ; end
  end
  named_scope :named_extension, :extend => NamedExtension
  named_scope :multiple_extensions, :extend => [MultipleExtensionTwo, MultipleExtensionOne]
  has_many    :replies, :dependent => :destroy, :foreign_key => 'parent_id'
end

class Reply < Topic
  named_scope :base
  belongs_to  :topic, :foreign_key => 'parent_id', :counter_cache => true
end

class AuthorAddress < ActiveRecord::Base ; end

class Comment < ActiveRecord::Base
  named_scope :containing_the_letter_e, :conditions => "comments.body LIKE '%e%'"
  belongs_to  :post, :counter_cache => true
end



