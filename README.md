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

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
