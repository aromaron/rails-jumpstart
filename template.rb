# Template Name: Rails Jumpstart
# Author: Nora Alvarado
# Instructions: $ rails new myapp --css tailwind --database=postgresql -m https://github.com/aromaron/rails-jumpstart/template.rb

def source_paths
  [__dir__]
end

def add_gems
  gem "devise", "~> 4.8"
  gem "friendly_id", "~> 5.4.0"
  gem "image_processing", "~> 1.2"
  gem "sidekiq", "~> 6.1.3"
  gem "name_of_person"
  gem "heroicon"

  gem_group :development, :test do
    gem "awesome_print"
    gem "bullet"
    gem "bundler-audit", ">= 0.7.0", require: false
    gem "database_cleaner"
    gem "factory_bot_rails"
    gem "faker"
    gem "pry-rails"
  end

  gem_group :development do
    gem "listen"
    gem "letter_opener"
    gem "standard"
  end

  gem_group :test do
    gem "simplecov", require: false
  end
end

def add_testing
  copy_file ".rubocop.yml"
end

def add_active_storage
  rails_command "active_storage:install"

  environment "config.active_storage.service = :local", env: "development"
end

def add_users
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: "development"

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, "User", "first_name", "last_name", "admin:boolean"

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob("db/migrate/*").max_by { |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  # name_of_person gem & active storage attachment
  append_to_file("app/models/user.rb", "\n\nhas_person_name\nhas_one_attached :avatar\n", after: ":recoverable, :rememberable, :validatable")
end

def copy_templates
  directory "app", force: true
end

def add_dark_theme
  copy_file "config/tailwind.config.js"
end

def add_heroicon
  run "rails g heroicon:install"
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"

  content = <<-RUBY
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY
  insert_into_file "config/routes.rb", "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_foreman
  copy_file "Procfile.dev"
end

def add_friendly_id
  generate "friendly_id"
end

def add_uuid
  copy_file "db/migrate/0_enable_uuid.rb"
  copy_file "config/initializers/generators.rb"
end

# Main setup
source_paths

add_gems

after_bundle do
  add_testing
  add_active_storage
  add_users
  add_sidekiq
  add_foreman
  copy_templates
  add_dark_theme
  add_heroicon
  add_friendly_id
  add_uuid

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  say
  say "Rails Jupstart app successfully created! 👍", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :yellow
  say
  say "Then run:"
  say "$ bin/dev", :green
end
