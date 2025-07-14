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

$schema.addProperty("name"; cs.PeD4ntic.JSONSchemaStringNode.new({ \
    minLength: 2; \
    maxLength: 50; \
    pattern: "^[a-zA-Z\\s]+$" \
}))
$schema.addProperty("email"; cs.PeD4ntic.JSONSchemaStringNode.new({format: "email"}))
$schema.required:=["name"; "email"]
$schema.additionalProperties:=False
```

#### Validate data against schema

```4d
var $userData:={name: "John"; email: "john@example.com"}

var $result:=$schema.validate($userData) // This use JSON Validate
```

### Parse 4D Classes

Create schema using property definition (work only with sources)

```4d
var $classFile:=Folder(fk database folder; *).file("Project/Sources/Classes/User.4dm")
var $schema:=cs.PeD4ntic.ClassParser.me.parseFile($classFile)
```

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

