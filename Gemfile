ruby '2.6.3'
source 'https://rubygems.org'

gem 'rails', '5.2.3'

# DB
gem 'mysql2', '>= 0.3.13', '< 0.5'

# LOD
gem 'httpclient'

# Asset
gem 'uglifier', '>= 1.3.0'

# View
gem 'kaminari'

# Security
gem 'devise'
gem 'bcrypt', '~> 3.1.7'
gem 'banken'

group :development, :test do
  gem 'byebug'
end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'rubocop'
  gem 'rails-erd'
end

group :production do
  gem 'unicorn', '~> 4.9.0'
  gem 'listen'
  gem 'unicorn-worker-killer', '~> 0.4.2'
end

gem 'foreman'