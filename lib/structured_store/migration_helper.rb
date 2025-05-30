module StructuredStore
  # Helper method for creating versioned schemas
  module MigrationHelper
    def create_versioned_schema(name, version)
      reversible do |dir|
        dir.up do
          json_schema_string = Rails.root.join("db/migration_versioned_schemas/#{name}-#{version}.json").read
          json_schema = JSON.parse(json_schema_string)
          ::StructuredStore::VersionedSchema.create(
            name: name,
            version: version,
            json_schema: json_schema
          )
        end
        dir.down do
          ::StructuredStore::VersionedSchema.where(name: name, version: version).destroy_all
        end
      end
    end
  end
end
