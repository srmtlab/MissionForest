ruby '2.3.1'
source 'https://rubygems.org'

gem 'rails', '4.2.6'

# DB
gem 'mysql2', '>= 0.3.13', '< 0.5'
gem 'pg'

# LOD
gem 'stardog-rb'

# Asset
gem 'uglifier', '>= 1.3.0'
gem "jquery-rails"

# View
gem 'kaminari'
gem 'meta-tags'
gem 'momentjs-rails'
gem 'bootstrap3-datetimepicker-rails'

# Security
gem 'devise'
gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'byebug'
  gem 'rails-erd'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rubocop'
  gem 'rails-erd'
end

group :unicorn do
  gem 'unicorn', '~> 4.9.0'
  gem 'unicorn-worker-killer', '~> 0.4.2'
end
