primary_key_type = options[:database].eql?("sqlite3") ? :text : :uuid

insert_into_file "config/initializers/generators.rb", after: "Rails.application.config.generators do |g|" do
  <<~RUBY.indent(2).prepend("\n").chomp
    g.orm :active_record, primary_key_type: :#{primary_key_type}
  RUBY
end

initializer "active_record.rb", <<~RUBY
  ActiveSupport.on_load(:active_record_postgresqladapter) do
    self.datetime_type = :timestamptz
  end
RUBY

unless options[:database].eql?("postgresql")
  insert_into_file "config/initializers/active_record.rb" do
    <<~RUBY.prepend("\n")
      ActiveRecord::Base.class_eval do
        before_create :assign_id

        private def assign_id
          if self.class.name.start_with?("ActiveStorage::")
            self.id ||= Util.generate_id
          end
        end
      end
    RUBY
  end

  insert_into_file "app/models/application_record.rb", before: /^end\s*$/ do
    <<~RUBY.indent(2).prepend("\n")
      before_create :assign_id

      private def assign_id
        self.id ||= Util.generate_id
      end
    RUBY
  end
end

unless options[:database].eql?("sqlite3")
  gsub_file "config/database.yml", /^\s*username:.*\n/, ""
  gsub_file "config/database.yml", /^\s*password:.*\n/, ""
  gsub_file "config/database.yml", /^\s*host:.*\n/, ""
  gsub_file "config/database.yml", /^\s*port:.*\n/, ""

  gsub_file "config/database.yml",
    "database: #{@app_name}_development",
    "database: <%= ENV[\"DATABASE_NAME\"] %>_development"

  gsub_file "config/database.yml",
    "database: #{@app_name}_test",
    "database: <%= ENV[\"DATABASE_NAME\"] %>_test"

  gsub_file "config/database.yml",
    "database: #{@app_name}_production",
    "database: <%= ENV[\"DATABASE_NAME\"] %>_production"

  gsub_file "config/database.yml",
    "database: #{@app_name}_production_cache",
    "database: <%= ENV[\"DATABASE_NAME\"] %>_production_cache"

  gsub_file "config/database.yml",
    "database: #{@app_name}_production_queue",
    "database: <%= ENV[\"DATABASE_NAME\"] %>_production_queue"

  gsub_file "config/database.yml",
    "database: #{@app_name}_production_cable",
    "database: <%= ENV[\"DATABASE_NAME\"] %>_production_cable"

  insert_into_file "config/database.yml", after: /encoding: .*\n/ do
    <<~YAML.indent(2)
      username: <%= ENV["DATABASE_USERNAME"] %>
      password: <%= ENV["DATABASE_PASSWORD"] %>
      host: <%= ENV["DATABASE_HOST"] %>
      port: <%= ENV["DATABASE_PORT"] %>
    YAML
  end
end
