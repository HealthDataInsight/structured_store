# StructuredStore

StructuredStore is a Ruby gem designed for Rails applications that provides a robust system for managing JSON data using versioned JSON schemas. The library enables developers to store structured data in a JSON database column while maintaining strict schema validation through the json_schemer gem.

It features a VersionedSchema model that tracks different versions of JSON schemas using semantic versioning, and a Storable concern that can be included in ActiveRecord models to automatically define accessor methods for schema properties. The gem supports schema evolution by allowing multiple versions of the same schema to coexist, making it ideal for applications that need to maintain backward compatibility while evolving their data structures.

With built-in Rails generators for easy setup and dynamic property resolution through a configurable resolver registry, StructuredStore simplifies the management of complex, schema-validated JSON data in database applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "structured_store"
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install structured_store
```

## Usage

StructuredStore provides a robust way to manage JSON data with versioned schemas in Rails applications. Here's how to use it:

### Basic Setup

After installation, create the necessary database tables:

```bash
$ rails generate structured_store:install
$ rails db:migrate
```

This creates a `structured_store_versioned_schemas` table and a `db/structured_store_versioned_schemas/` directory for your schema files.

### 1. Creating a JSON Schema

First, define your JSON schema by creating a JSON file in the `db/structured_store_versioned_schemas/` directory. The file should be named using the pattern `{name}-{version}.json`.

Create `db/structured_store_versioned_schemas/UserPreferences-1.0.0.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "type": "object",
  "properties": {
    "theme": {
      "type": "string",
      "description": "User interface theme preference",
      "default": "light",
      "examples": ["light", "dark", "system"]
    },
    "notifications": {
      "type": "boolean",
      "description": "Whether user notifications are enabled",
      "default": true
    },
    "language": {
      "type": "string",
      "description": "Preferred language",
      "default": "en"
    }
  },
  "required": ["theme"],
  "additionalProperties": false
}
```

Then create a migration to install the schema:

```ruby
# Generate a new migration
$ rails generate migration InstallUserPreferencesSchema

# Edit the migration file
class InstallUserPreferencesSchema < ActiveRecord::Migration[7.0]
  include StructuredStore::MigrationHelper

  def change
    create_versioned_schema("UserPreferences", "1.0.0")
  end
end
```

Run the migration:

```bash
$ rails db:migrate
```

### 2. Creating a Model with Structured Storage

Create a model that includes the `StructuredStore::Storable` concern:

```ruby
# app/models/user_preference.rb
class UserPreference < ApplicationRecord
  include StructuredStore::Storable
end
```

Generate and run a migration for your model:

```ruby
# db/migrate/xxx_create_user_preferences.rb
class CreateUserPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_preferences do |t|
      t.references :structured_store_versioned_schema, null: false, foreign_key: true
      t.json :store
      t.timestamps
    end
  end
end
```

### 3. Using the Structured Store

Once your model includes `StructuredStore::Storable`, it automatically gets accessor methods for all properties defined in the associated JSON schema:

```ruby
# Find the latest version of your schema
schema = StructuredStore::VersionedSchema.latest("UserPreferences")

# Create a new record
preference = UserPreference.create!(
  versioned_schema: schema,
  theme: "dark",
  notifications: false,
  language: "es"
)

# Access the structured data
preference.theme         # => "dark"
preference.notifications # => false
preference.language      # => "es"

# Update structured data
preference.update!(theme: "light", notifications: true)

# The data is stored in the JSON `store` column
preference.store # => {"theme"=>"light", "notifications"=>true, "language"=>"es"}
```

### 4. Schema Versioning

StructuredStore supports schema evolution. You can create new versions of your schema by adding new JSON files and creating migrations to install them.

Create `db/structured_store_versioned_schemas/UserPreferences-1.1.0.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "type": "object",
  "properties": {
    "theme": {
      "type": "string",
      "description": "User interface theme preference",
      "default": "light",
      "examples": ["light", "dark", "system"]
    },
    "notifications": {
      "type": "boolean", 
      "description": "Whether user notifications are enabled",
      "default": true
    },
    "language": {
      "type": "string",
      "description": "Preferred language",
      "default": "en"
    },
    "timezone": {
      "type": "string",
      "description": "User's timezone",
      "default": "UTC"
    }
  },
  "required": ["theme"],
  "additionalProperties": false
}
```

Create a migration to install the new schema version:

```ruby
class InstallUserPreferencesSchemaV110 < ActiveRecord::Migration[7.0]
  include StructuredStore::MigrationHelper

  def change
    create_versioned_schema("UserPreferences", "1.1.0")
  end
end
```

Existing records continue to work with their original schema, while new records can use the latest version:

```ruby
# Get the latest schema version
latest_schema = StructuredStore::VersionedSchema.latest("UserPreferences")

# Create a record with the new schema
new_preference = UserPreference.create!(
  versioned_schema: latest_schema,
  theme: "system",
  timezone: "America/New_York"
)

new_preference.timezone # => "America/New_York"
```

### 5. Schema Validation

All data is automatically validated against the associated JSON schema:

```ruby
preference = UserPreference.new(versioned_schema: schema)

# This will fail validation because 'theme' is required
preference.valid? # => false

# This will pass validation
preference.theme = "light"
preference.valid? # => true

# Invalid data types are rejected
preference.notifications = "invalid" # Will cause validation error
```

### 6. Working with Complex Data Types

StructuredStore includes a `JsonDateRangeResolver` for handling date ranges through JSON schema references. This resolver works with date range converters to transform natural language date strings into structured date ranges.

#### Using Date Ranges

To use date ranges, define a property in your JSON schema with the special reference:

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "type": "object",
  "properties": {
    "event_period": {
      "$ref": "external://structured_store/json_date_range/"
    }
  }
}
```

Then implement a `date_range_converter` method in your model:

```ruby
class EventRecord < ApplicationRecord
  include StructuredStore::Storable
  
  def date_range_converter
    @date_range_converter ||= StructuredStore::Converters::ChronicDateRangeConverter.new
  end
end
```

#### Working with Date Range Data

```ruby
# Create a record with a natural language date range
event = EventRecord.create!(
  versioned_schema: schema,
  event_period: "January 2024"
)

# The converter transforms this to structured data internally
event.store['event_period'] 
# => {"date1"=>"2024-01-01", "date2"=>"2024-01-31"}

# When accessed, it's converted back to the natural language format
event.event_period # => "Jan 2024"

# Other date range examples
event.update!(event_period: "between 1st and 15th January 2024")
event.update!(event_period: "2024") # Full year
```

#### Using Alternative Converters

The `ChronicDateRangeConverter` is the default, but you can implement custom converters that respond to `convert_to_dates` and `convert_to_string`:

```ruby
class CustomDateRangeConverter
  def convert_to_dates(value)
    # Your custom logic to parse date ranges
    # Should return [start_date, end_date]
  end
  
  def convert_to_string(date1, date2)
    # Your custom logic to format date ranges
    # Should return a string representation
  end
end

class MyModel < ApplicationRecord
  include StructuredStore::Storable
  
  def date_range_converter
    @date_range_converter ||= CustomDateRangeConverter.new
  end
end
```

### 7. Finding and Querying Schemas

```ruby
# Find the latest version of a schema
latest = StructuredStore::VersionedSchema.latest("UserPreferences")

# Find a specific version
specific = StructuredStore::VersionedSchema.find_by(name: "UserPreferences", version: "1.0.0")

# Get all versions of a schema
all_versions = StructuredStore::VersionedSchema.where(name: "UserPreferences")
                                               .order(:version)
```

### 8. Advanced Usage: Custom Reference Resolvers

StructuredStore includes a resolver system for handling JSON schema references. You can create custom resolvers by extending `StructuredStore::RefResolvers::Base`:

```ruby
class CustomResolver < StructuredStore::RefResolvers::Base
  def self.matching_ref_pattern
    /^#\/custom\//
  end

  def define_attribute
    lambda do |instance|
      # Define custom attribute behavior
    end
  end
end

# Register your custom resolver
CustomResolver.register
```

### Best Practices

1. **Version your schemas semantically**: Use semantic versioning (e.g., "1.0.0", "1.1.0", "2.0.0") to track schema changes.

2. **Use migrations for schema management**: Always use the `StructuredStore::MigrationHelper` and migrations to install schemas. This ensures proper version control and rollback capabilities.

3. **Organize schema files clearly**: Keep your JSON schema files in `db/structured_store_versioned_schemas/` with clear naming: `{SchemaName}-{version}.json`.

4. **Plan for backward compatibility**: When creating new schema versions, consider how existing data will be handled.

5. **Use meaningful schema names**: Choose descriptive names for your schemas that clearly indicate their purpose.

6. **Validate your JSON schemas**: Test your JSON schema files before creating migrations to ensure they're valid.

7. **Document your schemas**: Include clear descriptions for all properties in your JSON schemas.

8. **Use defaults wisely**: Provide sensible default values for optional properties to ensure data consistency.

9. **Version control schema files**: Keep your `.json` schema files in version control alongside your migrations.

10. **Test schema migrations**: Always test your schema installation migrations in development before deploying to production.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HealthDataInsight/structured_store. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/HealthDataInsight/structured_store/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the structured_store project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/HealthDataInsight/structured_store/blob/main/CODE_OF_CONDUCT.md).
