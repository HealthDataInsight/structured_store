# Configurable Store Columns with StructuredStore

The `StructuredStore::Storable` module now supports configurable store columns with elegant defaults, allowing you to:

1. **Use automatic defaults** - no configuration needed for simple cases
2. **Use a single custom-named store column** (e.g., `depot` instead of `store`)
3. **Use multiple store columns** within the same model
4. **Organize different types of structured data separately** while maintaining proper schema versioning

## Basic Usage

### Automatic Default (Zero Configuration)

```ruby
class User < ApplicationRecord
  include StructuredStore::Storable
  
  # That's it! No structured_store calls needed
end
```

This automatically creates:
- Store column: `store` (JSON field)
- Association: `store_versioned_schema` 
- Foreign key: `structured_store_store_versioned_schema_id`
- Schema access: `user.store_versioned_schema_json_schema`

### Single Custom Store Column

```ruby
class DepotRecord < ApplicationRecord
  include StructuredStore::Storable
  
  # Single store column called 'depot'
  structured_store :depot
end
```

This creates:
- Store column: `depot` (JSON field)
- Association: `depot_versioned_schema` 
- Foreign key: `structured_store_depot_versioned_schema_id`
- Schema access: `depot.depot_versioned_schema_json_schema`

### Single Store Column with Custom Schema Association

```ruby
class WarehouseRecord < ApplicationRecord
  include StructuredStore::Storable
  
  # Store column 'inventory' with custom schema association name
  structured_store :inventory, schema_name: 'warehouse_schema'
end
```

This creates:
- Store column: `inventory` (JSON field)
- Association: `warehouse_schema` 
- Foreign key: `structured_store_warehouse_schema_id`
- Schema access: `warehouse.warehouse_schema_json_schema`

### Traditional Store Column (Backward Compatible)

```ruby
class User < ApplicationRecord
  include StructuredStore::Storable
  
  # Traditional 'store' column
  structured_store :store
end
```

This creates:
- Store column: `store` (JSON field)
- Association: `store_versioned_schema` 
- Foreign key: `structured_store_store_versioned_schema_id`

### Multiple Store Columns

```ruby
class User < ApplicationRecord
  include StructuredStore::Storable
  
  # Multiple stores for different purposes
  structured_store :store                    # First store gets automatic accessor setup
  structured_store :metadata, schema_name: 'user_metadata' 
  structured_store :settings                # Creates 'settings_versioned_schema'
  structured_store :preferences, schema_name: 'user_preferences'
end
```

This creates:
- Store columns: `store`, `metadata`, `settings`, `preferences` (JSON fields)
- Associations: `store_versioned_schema`, `user_metadata`, `settings_versioned_schema`, `user_preferences`
- Foreign keys: `structured_store_store_versioned_schema_id`, `structured_store_user_metadata_id`, etc.
- Schema access: `user.store_versioned_schema_json_schema`, `user.user_metadata_json_schema`, etc.

## Important Notes

### No Automatic Default Store

**Breaking Change**: Models now require explicit `structured_store_column` calls. Including `StructuredStore::Storable` alone no longer automatically creates a 'store' column configuration.

```ruby
# This will NOT work (no store columns configured)
class BadExample < ApplicationRecord
  include StructuredStore::Storable
  # Missing structured_store_column calls!
end

# This WILL work
class GoodExample < ApplicationRecord
  include StructuredStore::Storable
  
  structured_store_column :depot  # Configures the store
end
```

### Automatic Store Behavior

- **All** configured stores get automatic accessor setup
- The `define_store_accessors!` callback processes all stores
- No need to manually call `define_store_accessors_for_column` unless you want to refresh accessors
- Each store has its own schema access method: `#{schema_name}_json_schema`

### Configuration Override

The automatic default only applies when no `structured_store` calls are made:
- **No calls**: Gets automatic `store` column with `store_versioned_schema` association
- **Any calls**: Only configured stores exist, no automatic defaults

## Database Migration Examples

### Single Custom Store

```ruby
class CreateDepotRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :depot_records do |t|
      t.string :name
      
      # Single store column called 'depot'
      t.json :depot
      
      # Foreign key to versioned schema
      t.references :structured_store_depot_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
                   
      t.timestamps
    end
  end
end
```

### Single Store with Custom Schema Association

```ruby
class CreateWarehouseRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :warehouse_records do |t|
      t.string :name
      
      # Single store column called 'inventory'
      t.json :inventory
      
      # Foreign key to versioned schema with custom name
      t.references :structured_store_warehouse_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
                   
      t.timestamps
    end
  end
end
```

### Multiple Store Columns

```ruby
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      
      # Store columns (JSON fields)
      t.json :store
      t.json :metadata
      t.json :settings
      t.json :preferences
      
      # Foreign keys to versioned schemas
      t.references :structured_store_store_versioned_schema, 
                   null: false, 
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.references :structured_store_user_metadata, 
                   null: false, 
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.references :structured_store_settings_versioned_schema, 
                   null: false, 
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.references :structured_store_user_preferences, 
                   null: false, 
                   foreign_key: { to_table: :structured_store_versioned_schemas }

      t.timestamps
    end
  end
end
```

## API Methods

### Class Methods

#### `structured_store(column_name, schema_name: nil)`

Configures a store column and its associated schema.

**Parameters:**
- `column_name` (String|Symbol): Name of the JSON store column
- `schema_name` (String|Symbol, optional): Name for the schema association. Defaults to `"#{column_name}_versioned_schema"`

**Examples:**
```ruby
# Default schema association name
structured_store :profile  # Creates 'profile_versioned_schema'

# Custom schema association name  
structured_store :metadata, schema_name: 'user_metadata'
```

### Instance Methods

#### `define_store_accessors_for_column(column_name)`

Manually define store accessors for a specific column.

```ruby
user = User.new
user.metadata_schema = some_schema
user.define_store_accessors_for_column('metadata')
```

#### `define_all_store_accessors!`

Define store accessors for all configured store columns.

```ruby
user = User.new
user.store_versioned_schema = profile_schema
user.user_metadata = metadata_schema
user.settings_versioned_schema = settings_schema
user.define_all_store_accessors!
```

#### Schema Access Methods

Each configured store gets helper methods:

```ruby
# For store column 'metadata' with schema 'user_metadata'
user.user_metadata_json_schema  # Returns the JSON schema hash

# For store column 'settings' with default schema 'settings_versioned_schema'  
user.settings_versioned_schema_json_schema  # Returns the JSON schema hash
```

## Working with Single Store

### Setting Up Schema

```ruby
# Create schema for depot
depot_schema = StructuredStore::VersionedSchema.create!(
  name: 'warehouse_inventory',
  version: '1.0.0',
  json_schema: {
    'type' => 'object',
    'properties' => {
      'item_code' => { 'type' => 'string' },
      'quantity' => { 'type' => 'integer' },
      'location' => { 'type' => 'string' }
    }
  }
)
```

### Using the Store

```ruby
depot = DepotRecord.new(name: 'Main Warehouse')

# Assign schema
depot.depot_versioned_schema = depot_schema

# Accessors are automatically defined for the primary (and only) store
depot.item_code = 'ABC123'
depot.quantity = 50
depot.location = 'A1-B2'

depot.save!
```

## Working with Multiple Stores

### Setting Up Schemas

```ruby
# Create different schemas for different purposes
profile_schema = StructuredStore::VersionedSchema.create!(
  name: 'user_profile',
  version: '1.0.0',
  json_schema: {
    'type' => 'object',
    'properties' => {
      'first_name' => { 'type' => 'string' },
      'last_name' => { 'type' => 'string' },
      'bio' => { 'type' => 'string' }
    }
  }
)

metadata_schema = StructuredStore::VersionedSchema.create!(
  name: 'user_metadata', 
  version: '1.0.0',
  json_schema: {
    'type' => 'object',
    'properties' => {
      'last_login' => { 'type' => 'string', 'format' => 'date-time' },
      'login_count' => { 'type' => 'integer' },
      'ip_address' => { 'type' => 'string' }
    }
  }
)

settings_schema = StructuredStore::VersionedSchema.create!(
  name: 'user_settings',
  version: '1.0.0', 
  json_schema: {
    'type' => 'object',
    'properties' => {
      'theme' => { 'type' => 'string', 'enum' => ['light', 'dark'] },
      'notifications' => { 'type' => 'boolean' },
      'language' => { 'type' => 'string' }
    }
  }
)
```

### Using the Stores

```ruby
user = User.new(email: 'user@example.com')

# Assign schemas to different stores
user.store_versioned_schema = profile_schema
user.user_metadata = metadata_schema  
user.settings_versioned_schema = settings_schema

# After initialization, accessors are automatically defined for the primary store
# But you can manually define them for other stores
user.define_store_accessors_for_column('metadata')
user.define_store_accessors_for_column('settings')

# Or define all at once
user.define_all_store_accessors!

# Now you can use the accessors
user.first_name = 'John'
user.last_name = 'Doe'
user.bio = 'Software developer'

user.last_login = Time.current.iso8601
user.login_count = 1
user.ip_address = '192.168.1.1'

user.theme = 'dark'
user.notifications = true
user.language = 'en'

user.save!
```

## Backward Compatibility

**Important**: This implementation introduces a **breaking change** for existing code. Models that previously worked by just including `StructuredStore::Storable` will now need explicit `structured_store_column` calls.

### Migrating Existing Code

**Fully Compatible**: No migration needed! Existing models that used the implicit `store` column will continue to work exactly as before.

**Before (still works):**
```ruby
class User < ApplicationRecord
  include StructuredStore::Storable
  # This still works - gets automatic default
end
```

**After:**
```ruby
class User < ApplicationRecord
  include StructuredStore::Storable
  
  # This achieves the same thing explicitly
  structured_store :store
end
```

**Note**: The association name is now consistent:
- **Automatic default**: `store_versioned_schema` association 
- **Explicit store**: `store_versioned_schema` association

Both work exactly the same way with consistent naming.

### Why This Change?

This change provides much more flexibility:
- **Single custom-named stores**: You can now have a model with just a `depot` column instead of being forced to use `store`
- **Multiple stores**: Multiple structured stores per model
- **Better naming**: More descriptive association names based on purpose
- **Explicit configuration**: Makes store configuration explicit and discoverable

## Primary Store Behavior

- The first store column configured (or 'store' if present) becomes the "primary" store
- The `json_schema` method delegates to the primary store's schema association
- The default `define_store_accessors!` callback only processes the primary store
- To work with multiple stores, use `define_store_accessors_for_column` or `define_all_store_accessors!`

## Configuration Details

Each `structured_store` call:

1. **Stores Configuration**: Saves column name, schema association name, and foreign key name in `_structured_store_configurations`
2. **Creates Association**: Defines a `belongs_to` relationship to `StructuredStore::VersionedSchema`
3. **Defines Helper Method**: Creates a `#{schema_name}_json_schema` method
4. **Automatic Setup**: All stores get accessors defined automatically on instance initialization

### Store Configuration

The **stores** are processed in the order they are configured:
- `_structured_store_configurations` is an array that maintains insertion order
- All stores get equal treatment - no special "first store" behavior
- Simple and consistent - every store works the same way

The configuration is stored in:
- `_structured_store_configurations`: Array of all store configurations

## Error Handling

The system gracefully handles missing schemas:

- If no schema is assigned to a store, accessor definition is skipped
- Logging provides clear information about missing schemas
- Methods check for sufficient information before proceeding
- Invalid schema properties are logged with warnings

This allows for flexible development and testing scenarios where not all schemas may be immediately available.
