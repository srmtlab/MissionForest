ruby '2.6.3'
source 'https://rubygems.org'

gem 'rails', '5.2.3'

# DB
gem 'mysql2', '>= 0.3.13', '< 0.5'
gem 'redis-rails'

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

# Use Puma as the app server
gem 'puma'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]  
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring'
  gem 'rubocop'
  gem 'rails-erd'
  # Provide a comprehensive suite of tools for Ruby programming. Read more: https://github.com/castwide/solargraph
  gem 'solargraph'  
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]