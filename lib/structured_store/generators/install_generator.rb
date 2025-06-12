require 'rails/generators'
require 'rails/generators/base'

module StructuredStore
  module Generators
    # This generator creates a migration for the structured store versioned schemas table
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      desc 'Creates a migration for the structured store tables'

      # This method is required when including Rails::Generators::Migration
      def self.next_migration_number(_dirname)
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      end

      def create_migration_file
        migration_template 'create_structured_store.rb', 'db/migrate/create_structured_store.rb'
      end

      def create_schemas_directory
        directory_path = 'db/structured_store_versioned_schemas'
        keep_file_path = File.join(directory_path, '.keep')

        # Create the directory if it doesn't exist
        empty_directory directory_path

        # Create the .keep file
        create_file keep_file_path
      end

      private

      def migration_version
        "[#{ActiveRecord::Migration.current_version}]"
      end
    end
  end
end
