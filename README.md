# PeD4ntic

A 4D component for generating JSON Schema from 4D classes and data structures. Born from a pedantic love of following rules and standards, PeD4ntic ensures your 4D data models conform to proper JSON Schema specifications. Because when it comes to data validation, being pedantic about the rules is exactly what you want.

## Usage

### Basic JSON Schema Creation

#### Create schema with object definition

```4d
var $schema:=cs.PeD4ntic.JSONSchema.new({ \
    title: "User"; \
    description: "A user object"; \
    type: "object"; \
    properties: { \
        name: { \
            type: "string"; \
            minLength: 2; \
            maxLength: 50; \
            pattern: "^[a-zA-Z\\s]+$" \
        }; \
        email: { \
            type: "string"; \
            format: "email" \
        } \
    }; \
    required: ["name"; "email"]; \
    additionalProperties: False \
})
```

#### Create schema using addProperty method

```4d
$schema:=cs.PeD4ntic.JSONSchema.new({title: "User"; description: "A user object"})

$schema.addStringProperty("name"; { \
    minLength: 2; \
    maxLength: 50; \
    pattern: "^[a-zA-Z\\s]+$" \
})
$schema.addStringProperty("email"; {format: "email"})
$schema.addIntegerProperty("age"; {minimum: 0; maximum: 150})
$schema.addBooleanProperty("active"; {})
$schema.addArrayProperty("tags"; {minItems: 1; uniqueItems: True})
$schema.setRequired(["name"; "email"])
$schema.setAdditionalProperties(False)
```

#### Validate data against schema

```4d
var $userData:={name: "John"; email: "john@example.com"}

var $result:=$schema.validate($userData) // This use JSON Validate
```

### Parse 4D Classes

Create schema using property definitions in source files

```4d
var $classFile:=Folder(fk database folder; *).file("Project/Sources/Classes/User.4dm")
var $schema:=cs.PeD4ntic.ClassParser.me.parseFile($classFile)
```

If one class depends on another, use `addDefinition` to include it.

### Parse Data Classes

```4d
var $schema:=cs.PeD4ntic.DataClassParser.me.parse(ds.Users)
```

> - blog, picture are ignored
> - date do not work yet

## Requirements

- 4D with a `Trim` function

## License

MIT License

