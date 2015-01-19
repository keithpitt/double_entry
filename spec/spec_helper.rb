# encoding: utf-8
require 'bundler/setup'
require 'active_record'
require 'active_support'

db_engine = ENV['DB'] || 'mysql'

ActiveRecord::Base.establish_connection YAML.load_file(File.expand_path("../support/database.yml", __FILE__))[db_engine]

FileUtils.mkdir_p 'log'
FileUtils.rm 'log/test.log', :force => true

# Buffered Logger was deprecated in ActiveSupport 4.0.0 and was removed in 4.1.0
# Logger was added in ActiveSupport 4.0.0
if defined? ActiveSupport::Logger
  ActiveRecord::Base.logger = ActiveSupport::Logger.new('log/test.log')
else
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new('log/test.log')
end

I18n.config.enforce_available_locales = false

require 'double_entry'
require 'rspec'
require 'rspec/its'
require 'database_cleaner'
require 'machinist/active_record'
require 'timecop'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.include DoubleEntrySpecHelper

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    Timecop.return
    DatabaseCleaner.clean
  end
end
