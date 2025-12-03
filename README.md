# StructuredStore

StructuredStore is a Ruby gem designed for Rails applications that provides a robust system for managing JSON data using versioned JSON schemas. The library enables developers to store structured data in a JSON database column while maintaining strict schema validation through the json_schemer gem.

It features a VersionedSchema model that tracks different versions of JSON schemas using semantic versioning, and a Storable concern that can be included in ActiveRecord models to automatically define accessor methods for schema properties. The gem supports schema evolution by allowing multiple versions of the same schema to coexist, making it ideal for applications that need to maintain backward compatibility while evolving their data structures.

With a built-in Rails generator for reliable setup and dynamic property resolution through a configurable resolver registry, StructuredStore simplifies the management of complex, schema-validated JSON data in database applications.

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
rails generate structured_store:install
rails db:migrate
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
      "description": "User interface theme preference"
      "examples": ["light", "dark", "system"]
    },
    "notifications": {
      "type": "boolean",
      "description": "Whether user notifications are enabled"
    },
    "language": {
      "type": "string",
      "description": "Preferred language"
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
rails db:migrate
```

### 2. Creating a Model with Structured Storage

Create a model that includes the `StructuredStore::Storable` concern and explicitly configure the structured store column(s):

```ruby
# app/models/user_preference.rb
class UserPreference < ApplicationRecord
  include StructuredStore::Storable

  # Must explicitly configure structured store column(s)
  structured_store :preferences
end
```

Generate and run a migration for your model (for advanced configuration options like custom foreign keys, see section 9):

```ruby
# db/migrate/xxx_create_user_preferences.rb
class CreateUserPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_preferences do |t|
      t.references :structured_store_preferences_versioned_schema, null: false, foreign_key: { to_table: :structured_store_versioned_schemas }
      t.json :preferences
      t.timestamps
    end
  end
end
```

### 3. Using the Structured Store

Once your model includes `StructuredStore::Storable` and configures structured stores, it automatically gets accessor methods for all properties defined in the associated JSON schema:

```ruby
# Find the latest version of your schema
schema = StructuredStore::VersionedSchema.latest("UserPreferences")

# Create a new record
preference = UserPreference.create!(
  preferences_versioned_schema: schema,
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

# The data is stored in the JSON `preferences` column
preference.preferences # => {"theme"=>"light", "notifications"=>true, "language"=>"es"}
```

If you chose to alter the migration to use a column type other than `json` or `jsonb`, you will need to amend your model to define the store and JSON serialiser (aka coder):

```ruby
# app/models/user_preference.rb
class UserPreference < ApplicationRecord
  include StructuredStore::Storable

  # Declare the ActiveRecord::Store and coder for unstructured database data types
  store :preferences, coder: JSON

  # Declare that the structured store using the unstructured preferences column
  structured_store :preferences
end
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
      "examples": ["light", "dark", "system"]
    },
    "notifications": {
      "type": "boolean",
      "description": "Whether user notifications are enabled"
    },
    "language": {
      "type": "string",
      "description": "Preferred language"
    },
    "timezone": {
      "type": "string",
      "description": "User's timezone"
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
  preferences_versioned_schema: latest_schema,
  theme: "system",
  timezone: "America/New_York"
)

new_preference.timezone # => "America/New_York"
```

### 5. Schema Validation

All data is automatically validated against the associated JSON schema:

```ruby
preference = UserPreference.new(preferences_versioned_schema: schema)

# This will fail validation because 'theme' is required
preference.valid? # => false

# This will pass validation
preference.theme = "light"
preference.valid? # => true

# Invalid data types are rejected
preference.notifications = "invalid" # Will cause validation error
```

### 6. Working with Array Properties

StructuredStore supports JSON schema properties with `type: "array"` for both arrays with `$ref` items and arrays with direct type items.

#### Arrays with Direct Type Items

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "type": "object",
  "properties": {
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "List of tags"
    }
  }
}
```

```ruby
schema = StructuredStore::VersionedSchema.create!(
  name: 'BlogPost',
  version: '1.0.0',
  json_schema: schema
)

post = BlogPost.new(data_versioned_schema: schema)
post.tags = ['ruby', 'rails', 'testing']
post.save!

post.tags # => ['ruby', 'rails', 'testing']
```

#### Arrays with $ref Items

```json
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "type": "object",
  "definitions": {
    "status_type": {
      "type": "string",
      "enum": ["pending", "active", "completed"]
    }
  },
  "properties": {
    "statuses": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/status_type"
      },
      "description": "List of statuses"
    }
  }
}
```

```ruby
schema = StructuredStore::VersionedSchema.create!(
  name: 'Workflow',
  version: '1.0.0',
  json_schema: schema
)

workflow = Workflow.new(data_versioned_schema: schema)
workflow.statuses = ['pending', 'active']
workflow.save!

workflow.statuses # => ['pending', 'active']
```

**Supported item types:** `string`, `integer`, `boolean`

**Note:** Arrays with `object` or other complex item types are not currently supported.

### 7. Working with Complex Data Types

StructuredStore includes a `JsonDateRangeResolver` for handling date ranges through JSON schema references. This resolver works with date range converters to transform natural language date strings into structured date ranges.

#### Using Date Ranges

To use date ranges, define a property in your JSON schema with the custom reference:

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

Then implement a `date_range_converter` method in your model and require the optional `JsonDateRangeResolver`:

```ruby
require 'structured_store/ref_resolvers/defaults'
require 'structured_store/ref_resolvers/json_date_range_resolver'

class EventRecord < ApplicationRecord
  include StructuredStore::Storable

  structured_store :event_data

  def date_range_converter
    @date_range_converter ||= StructuredStore::Converters::ChronicDateRangeConverter.new
  end
end
```

If you choose to use the `ChronicDateRangeConverter`, you will also need to add `chronic` to your application's Gemfile.

#### Working with Date Range Data

```ruby
# Create a record with a natural language date range
event = EventRecord.create!(
  event_data_versioned_schema: schema,
  event_period: "January 2024"
)

# The converter transforms this to structured data internally
event.event_data['event_period']
# => {"date1"=>"2024-01-01 00:00:00", "date2"=>"2024-01-31 00:00:00"}

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

  structured_store :data

  def date_range_converter
    @date_range_converter ||= CustomDateRangeConverter.new
  end
end
```

### 8. Finding and Querying Schemas

```ruby
# Find the latest version of a schema
latest = StructuredStore::VersionedSchema.latest("UserPreferences")

# Find a specific version
specific = StructuredStore::VersionedSchema.find_by(name: "UserPreferences", version: "1.0.0")

# Get all versions of a schema
all_versions = StructuredStore::VersionedSchema.where(name: "UserPreferences")
                                               .order(:version)
```

### 9. Custom Schema Names and Association Options

StructuredStore provides flexibility in configuring your schema associations. The `structured_store` method accepts any `belongs_to` options via the `**belongs_to_options` parameter:

```ruby
class Product < ApplicationRecord
  include StructuredStore::Storable

  # Default naming: creates belongs_to :config_versioned_schema
  # with foreign_key: 'structured_store_config_versioned_schema_id'
  # and class_name: 'StructuredStore::VersionedSchema'
  structured_store :config

  # Custom schema name: creates belongs_to :product_configuration
  # with foreign_key: 'structured_store_product_configuration_id'
  structured_store :settings, schema_name: 'product_configuration'

  # Custom foreign key: creates belongs_to :metadata_versioned_schema
  # with foreign_key: 'custom_metadata_fk'
  structured_store :metadata, foreign_key: 'custom_metadata_fk'

  # Custom class name for using a different schema model
  structured_store :advanced_config, class_name: 'CustomSchema'

  # Multiple custom options
  structured_store :options,
                   schema_name: 'product_options',
                   foreign_key: 'options_schema_id',
                   class_name: 'ProductSchema'
end
```

#### Using Custom Schema Models

You can associate with custom schema models that have non-conventional primary keys:

```ruby
# Custom schema model with non-standard primary key
class CustomSchema < ApplicationRecord
  self.primary_key = 'schema_key'
end

class Product < ApplicationRecord
  include StructuredStore::Storable

  # Associate with CustomSchema using its custom primary key
  structured_store :settings,
                   schema_name: 'custom_schema',
                   class_name: 'CustomSchema',
                   foreign_key: 'custom_schema_key',
                   primary_key: 'schema_key'
end
```

#### Additional belongs_to Options

Since all keyword arguments are passed through to `belongs_to`, you can use any standard Rails association options:

```ruby
class Product < ApplicationRecord
  include StructuredStore::Storable

  # Make the association optional
  structured_store :config, optional: true

  # Specify inverse_of
  structured_store :settings,
                   class_name: 'CustomSchema',
                   inverse_of: :products

  # Enable touch
  structured_store :metadata, touch: true
end
```

For complete working examples, see:

- `test/dummy/app/models/custom_foreign_key_record.rb` - Custom foreign key example
- `test/dummy/app/models/custom_primary_key_record.rb` - Custom primary key and class name example

### 10. Configurable Store Columns

StructuredStore supports configurable store columns, allowing you to use alternative column names for a single store (e.g., `depot` instead of `store`) or configure multiple store columns within the same model. This enables you to organize different types of structured data separately while maintaining proper schema versioning.

For detailed information on configuring single custom stores and multiple stores, see the [Custom Stores documentation](docs/custom_stores.md).

### 11. Advanced Usage: Custom Reference Resolvers

StructuredStore includes a resolver system for handling JSON schema references. You can create custom resolvers by extending `StructuredStore::RefResolvers::Base`:

```ruby
class CustomResolver < StructuredStore::RefResolvers::Base
  def self.matching_ref_pattern
    /^external:\/\/my_custom_type\//
  end

  def define_attribute
    # Access property_schema to get the property's JSON schema
    type = property_schema['type']

    lambda do |object|
      # Define custom attribute behavior on the object
      object.singleton_class.attribute(property_name, type.to_sym)
    end
  end

  def options_array
    # Return array of [value, label] pairs for form selects
    # Access parent_schema.definition_schema(name) if you need to look up definitions
    []
  end
end

# Register your custom resolver
CustomResolver.register
```

**Available instance variables in your resolver:**

- `property_schema` - The property's JSON schema hash
- `parent_schema` - The parent SchemaInspector for looking up definitions
- `property_name` - The property name (for error messages)
- `ref_string` - The `$ref` value
- `context` - Additional context hash

### Best Practices

1. **Version your schemas semantically**: Use semantic versioning (e.g., "1.0.0", "1.1.0", "2.0.0") to track schema changes.

2. **Use migrations for schema management**: Always use the `StructuredStore::MigrationHelper` and migrations to install schemas. This ensures proper version control and rollback capabilities.

3. **Organize schema files consistently**: Keep your JSON schema files in `db/structured_store_versioned_schemas/` with clear naming: `{SchemaName}-{version}.json`.

4. **Plan for backward compatibility**: When creating new schema versions, consider how existing data will be handled.

5. **Use meaningful schema names**: Choose descriptive names for your schemas that indicate their purpose.

6. **Validate your JSON schemas**: Test your JSON schema files before creating migrations to ensure they're valid.

7. **Document your schemas**: Include clear descriptions for all properties in your JSON schemas.

8. **JSON schema defaults**: Given the attribute lifecycle, StructuredStore does not support JSON Schema property defaults.

9. **Version control schema files**: Keep your `.json` schema files in version control alongside your migrations.

10. **Test schema migrations**: Always test your schema installation migrations in development before deploying to production.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/HealthDataInsight/structured_store>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/HealthDataInsight/structured_store/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the structured_store project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/HealthDataInsight/structured_store/blob/main/CODE_OF_CONDUCT.md).
