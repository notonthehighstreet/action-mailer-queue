$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

require "rubygems"
require "bundler"

if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.5")
  raise RuntimeError, "Your bundler version is too old." +
   "Run `gem install bundler` to upgrade."
end

# Set up load paths for all bundled gems
Bundler.setup

Bundler.require

require "active_record"
require "action_mailer"
require "mail"
require "active_support/core_ext/logger"

ENV['DB'] ||= 'mysql'

database_yml = File.expand_path('../database.yml', __FILE__)
active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]

ActiveRecord::Base.establish_connection(active_record_configuration)
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  
  load(File.dirname(__FILE__) + '/schema.rb')
  load(File.dirname(__FILE__) + '/models.rb')
end  

def clean_database!
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
  end
end

RSpec.configure do |config|
  config.before do
    ActionMailer::Base.active_record_settings[:table_name] = "emails"
    ActionMailer::Base.delivery_method = :test
    ActionMailerQueue::Mailer.delivery_method = :test
    clean_database!
  end
end

require File.expand_path('../../lib/action_mailer_queue', __FILE__)

clean_database!
