
Factory.sequence(:id)           { |n| n }
Factory.sequence(:email)        { |n| "test#{n}@domain.com" }
Factory.sequence(:topic_title)  { |n| "Topic Title ##{n}" }
Factory.sequence(:post_title)   { |n| "Post Title ##{n}" }
Factory.sequence(:comment_body) { |n| "Comment body ##{n}." }

Factory.define :author do |a|
  a.name      { "Factory Author ##{Factory.next(:id)}" }
end

Factory.define :topic do |t|
  t.title       { Factory.next(:topic_title) }
  t.content     'Have a nice day'
  t.approved    false
  t.written_on  { Time.now.to_s(:db) }
end

Factory.define :post do |p|
  p.title     { Factory.next(:post_title) }
  p.body      'Such a lovely day'
  p.comments  { |p| [p.association(:comment), p.association(:comment)] }
end

Factory.define :comment do |c|
  c.body          { Factory.next(:comment_body) }
  c.add_attribute :type,  'Comment'
end

Factory.define :david_with_posts, :class => 'Author' do |a|
  a.name      'David'
  a.posts     { |post| [post.association(:post), post.association(:post)] }
end

Factory.define(:author_address, :class => 'AuthorAddresss') do |aa|
  aa.add_attribute :id, Factory.next(:id)
end

