source 'https://rubygems.org'

gemspec

rails_version = case ENV['RAILS_VERSION']
  when 'master'
    [github: 'rails/rails']
  when '5.2'
    ['>= 5.2.0.rc1', '< 6.0']
  when '5.1'
    ['>= 5.1', '< 5.2']
  when '5.0'
    ['>= 5.0', '< 5.1']
  else
    ['>= 5.0', '<= 5.2.0.rc1']
end

group :development, :test do
  gem 'bundler', '>= 1.13'
  gem 'database_cleaner', '~> 1.6'
  gem 'pg', '~> 0.18'
  gem 'pry', '> 0'
  gem 'rake', '>= 10.0'
  gem 'rspec', '>= 3.0', '< 4'
  gem 'rails', *rails_version
end
