require File.dirname(__FILE__) + '/helper'

class NamedScopeTest < NamedScope::TestCase
  
  def setup
    setup_environment
    @topic1 = Factory :topic, :approved => false, :author_name => 'David', :replies_count => 1
    @topic2 = Factory :topic, :approved => true, :author_name => 'Nick', :replies_count => 1
    @reply1 = Factory :topic, :approved => true, :author_name => 'Mary', :type => 'Reply', :parent_id => @topic1.id
    @reply2 = Factory :topic, :approved => true, :author_name => 'Carl', :type => 'Reply', :parent_id => @topic2.id
    @david = Factory :david_with_posts
  end
  
  
  context 'Extra tests for plugin' do

    should 'allow :all scope for classes' do
      assert_same_elements Topic.find(:all), Topic.all
    end

  end
  
  
  context 'Tests from Rails 2.1.1' do
    
    should 'implement enumerable' do
      assert !Topic.find(:all).empty?
      assert_equal Topic.find(:all),   Topic.base
      assert_equal Topic.find(:all),   Topic.base.to_a
      assert_equal Topic.find(:first), Topic.base.first
      assert_equal Topic.find(:all),   Topic.base.each { |i| i }
    end
    
    should 'cache found items' do
      Topic.columns
      all_posts = Topic.base
      assert_queries(1) do
        all_posts.collect
        all_posts.collect
      end
    end
    
    should 'reload expires cache of found items' do
      all_posts = Topic.base
      all_posts.inspect
      new_post = Topic.create!
      assert !all_posts.include?(new_post)
      assert all_posts.reload.include?(new_post)
    end
    
    should 'delegate finds and calculations to the base class' do
      assert !Topic.find(:all).empty?
      assert_equal Topic.find(:all),               Topic.base.find(:all)
      assert_equal Topic.find(:first),             Topic.base.find(:first)
      assert_equal Topic.count,                    Topic.base.count
      assert_equal Topic.average(:replies_count),  Topic.base.average(:replies_count)
    end
    
    should 'scope respond_to own methods and methods of the proxy' do
      assert Topic.approved.respond_to?(:proxy_found)
      assert Topic.approved.respond_to?(:count)
      assert Topic.approved.respond_to?(:length)
    end
    
    should 'respond_to private parameter' do
      assert !Topic.approved.respond_to?(:load_found)
      assert Topic.approved.respond_to?(:load_found, true)
    end
    
    should 'inherit scopes for subclasses' do
      assert Topic.scopes.include?(:base)
      assert Reply.scopes.include?(:base)
      assert_equal Reply.find(:all), Reply.base
    end
    
    should 'limit finds for scopes with options to those criteria' do
      assert !Topic.find(:all, :conditions => {:approved => true}).empty?
      assert_equal Topic.find(:all, :conditions => {:approved => true}), Topic.approved
      assert_equal Topic.count(:conditions => {:approved => true}), Topic.approved.count
    end
    
    should 'compose scopes with string name' do
      assert_equal Topic.replied.approved, Topic.replied.approved_as_string
    end
    
    should 'compose scopes' do
      assert_equal((approved = Topic.find(:all, :conditions => {:approved => true})), Topic.approved)
      assert_equal((replied = Topic.find(:all, :conditions => 'replies_count > 0')), Topic.replied)
      assert !(approved == replied)
      assert !(approved & replied).empty?
      assert_equal approved & replied, Topic.approved.replied
    end
    
    should 'find same elements for procedural scope as standard finds would' do
      topic_before = Factory :topic, :written_on => 2.days.ago
      topic_criteron = Factory :topic, :written_on => 1.day.ago
      topic_before_byfind = Topic.find(:all, :conditions => ['written_on < ?', topic_criteron.written_on])
      assert_same_elements topic_before_byfind, Topic.written_before(topic_criteron.written_on)
      assert_same_elements [topic_before], Topic.written_before(topic_criteron.written_on)
    end
    
    context 'with addresses' do

      setup do
        @address = Factory(:author_address)
        @david.update_attribute :author_address_id, @address.id
      end

      should 'use scopes with joins' do
        posts_with_authors_at_address = Post.find(
          :all, :joins => 'JOIN authors ON authors.id = posts.author_id', :select => 'posts.*',
          :conditions => [ 'authors.author_address_id = ?', @address.id ]
        )
        assert_same_elements posts_with_authors_at_address, Post.with_authors_at_address(@address).find(:all,:select => 'posts.*')
      end
      
      should 'respect custom select' do
        posts_with_authors_at_address_titles = Post.find(:all,
          :select => 'title',
          :joins => 'JOIN authors ON authors.id = posts.author_id',
          :conditions => [ 'authors.author_address_id = ?', @address.id ]
        )
        assert_equal posts_with_authors_at_address_titles, Post.with_authors_at_address(@address).find(:all, :select => 'title')
      end
      
    end
    
    context 'for extensions' do

      should 'be there' do
        assert_equal 1, Topic.anonymous_extension.one
        assert_equal 2, Topic.named_extension.two
      end
      
      should 'work for multiple extensions' do
        assert_equal 2, Topic.multiple_extensions.extension_two
        assert_equal 1, Topic.multiple_extensions.extension_one
      end

    end
    
    should 'allow has_many associations to access to named_scopes' do
      no_a_post = Factory :post, :body => 'NOT HERE'
      @david.posts << no_a_post
      assert_not_equal Post.containing_the_letter_a, @david.posts
      assert !Post.containing_the_letter_a.empty?
      assert_same_elements @david.posts & Post.containing_the_letter_a, @david.posts.containing_the_letter_a
    end
    
    should 'allow has_many_through associations to access named_scopes' do
      no_e_comment = Factory :comment, :body => 'Naysay!', :post_id => @david.posts.first.id
      assert_not_equal Comment.containing_the_letter_e, @david.comments
      assert !Comment.containing_the_letter_e.empty?
      assert_same_elements @david.comments & Comment.containing_the_letter_e, @david.comments.containing_the_letter_e
    end
    
    should 'have a scope named all' do
      assert !Topic.find(:all).empty?
      assert_equal Topic.find(:all), Topic.base
    end
    
    should 'have scope named scope' do
      assert !Topic.find(:all, scope = {:conditions => "content LIKE '%Have%'"}).empty?
      assert_equal Topic.find(:all, scope), Topic.scoped(scope)
    end
    
    should 'return proxy options for named scopes' do
      expected_proxy_options = { :conditions => { :approved => true } }
      assert_equal expected_proxy_options, Topic.approved.proxy_options
    end
    
    should 'support first and last find options' do
      assert_equal Topic.base.first(:order => 'title'), Topic.base.find(:first, :order => 'title')
      assert_equal Topic.base.last(:order => 'title'), Topic.base.find(:last, :order => 'title')
    end
    
    should 'allow integers for first and last' do
      id = @topic1.id
      assert_equal Topic.base.first(id), Topic.base.to_a.first(id)
      assert_equal Topic.base.last(id), Topic.base.to_a.last(id)
    end
    
    should 'not query db when first and last results are loaded' do
      topics = Topic.base
      topics.reload # force load
      assert_no_queries do
        topics.first
        topics.last
      end
    end
    
    should 'use query when first and last results are loaded' do
      topics = Topic.base
      topics.reload # force load
      assert_queries(2) do
        topics.first(:order => 'title')
        topics.last(:order => 'title')
      end
    end
    
    should 'not load results for empty?' do
      topics = Topic.base
      assert_queries(2) do
        topics.empty?  # use count query
        topics.collect # force load
        topics.empty?  # use loaded (no query)
      end
    end
    
    should 'behave like select for find_all' do
      assert_equal Topic.base.select(&:approved), Topic.base.find_all(&:approved)
    end
    
    should 'select a random object from proxy using rand' do
      assert Topic.approved.rand.is_a?(Topic) unless rails_126?
    end
    
    should 'use where in query for named_scope' do
      assert_equal Author.find_all_by_name('David'), Author.find_all_by_id(Author.davids)
    end
    
  end
  
  
end

