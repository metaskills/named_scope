require 'rubygems'

plugin_root     = File.expand_path(File.join(File.dirname(__FILE__),'..'))
framework_root  = ["#{plugin_root}/rails", "#{plugin_root}/../../rails"].detect { |p| File.directory? p }
rails_version   = ENV['RAILS_VERSION']
rails_version   = '2.0.4' if rails_version && rails_version == ''

['.','lib','test'].each do |plugin_lib|
  load_path = File.expand_path("#{plugin_root}/#{plugin_lib}")
  $LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)
end

if rails_version.nil? && framework_root
  puts "Found framework root: #{framework_root}"
  $:.unshift "#{framework_root}/activesupport/lib", "#{framework_root}/activerecord/lib"
else
  puts "Using rails#{" #{rails_version}" if rails_version} from gems"
  if rails_version
    gem 'rails', rails_version
  else
    gem 'activerecord'
  end
end

require 'active_record'
require 'active_support'

