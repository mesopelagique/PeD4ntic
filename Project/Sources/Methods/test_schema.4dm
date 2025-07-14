//%attributes = {}
// Test the refactored JSONSchema classes

// Test 1: Basic JSONSchema creation (should work as before)
var $schema : cs:C1710.JSONSchema
$schema:=cs:C1710.JSONSchema.new({title: "User"; description: "A user object"})

ASSERT:C1129($schema.type="object"; "Schema should be object type")
ASSERT:C1129($schema["$schema"]="http://json-schema.org/draft-04/schema#"; "Should have default schema version")
ASSERT:C1129($schema.title="User"; "Should preserve title")

// Test 2: Using specialized node types
var $stringNode : cs:C1710.JSONSchemaStringNode
$stringNode:=cs:C1710.JSONSchemaStringNode.new({maxLength: 255; minLength: 1})

var $numberNode : cs:C1710.JSONSchemaNumberNode
$numberNode:=cs:C1710.JSONSchemaNumberNode.new({minimum: 0; maximum: 100})

var $booleanNode : cs:C1710.JSONSchemaBooleanNode
$booleanNode:=cs:C1710.JSONSchemaBooleanNode.new()

// Test 2b: Using JSONSchemaObjectNode for nested objects
var $addressNode : cs:C1710.JSONSchemaObjectNode
$addressNode:=cs:C1710.JSONSchemaObjectNode.new({description: "User address"})
$addressNode.addProperty("street"; cs:C1710.JSONSchemaStringNode.new({maxLength: 100}))
$addressNode.addProperty("city"; cs:C1710.JSONSchemaStringNode.new({maxLength: 50}))
$addressNode.addProperty("zipCode"; cs:C1710.JSONSchemaStringNode.new({pattern: "^[0-9]{5}$"}))
$addressNode.setRequired(["street"; "city"])
$addressNode.setAdditionalProperties(False:C215)

// Test 3: Building a complex schema using the new API
var $userSchema : cs:C1710.JSONSchema
$userSchema:=cs:C1710.JSONSchema.new({title: "User"; description: "User profile schema"})

$userSchema.addProperty("name"; $stringNode)
$userSchema.addProperty("age"; $numberNode)
$userSchema.addProperty("isActive"; $booleanNode)
$userSchema.addProperty("address"; $addressNode)  // Add nested object
$userSchema.setRequired(["name"; "age"])

// Test 4: Verify the generated schema structure
var $schemaObject : Object
$schemaObject:=$userSchema.toObject()

ASSERT:C1129($schemaObject.type="object"; "Root should be object")
ASSERT:C1129($schemaObject.properties.name.type="string"; "Name should be string type")
ASSERT:C1129($schemaObject.properties.name.maxLength=255; "Name should have maxLength")
ASSERT:C1129($schemaObject.properties.age.type="number"; "Age should be number type")
ASSERT:C1129($schemaObject.properties.age.minimum=0; "Age should have minimum")
ASSERT:C1129($schemaObject.properties.isActive.type="boolean"; "isActive should be boolean type")
ASSERT:C1129($schemaObject.properties.address.type="object"; "Address should be object type")
ASSERT:C1129($schemaObject.properties.address.properties.street.type="string"; "Street should be string type")
ASSERT:C1129($schemaObject.properties.address.additionalProperties=False:C215; "Address should not allow additional properties")
ASSERT:C1129($schemaObject.required.length=2; "Should have 2 required fields")

// Test 5: Validation should still work
var $testUser : Object:={name: "John Doe"; age: 30; isActive: True:C214; address: {street: "123 Main St"; city: "Anytown"; zipCode: "12345"}}
var $validation : Object:=$userSchema.validate($testUser)
ASSERT:C1129($validation.success; "Valid user should pass validation")

var $invalidUser : Object:={age: -5}  // Missing required name, invalid age
var $invalidValidation : Object:=$userSchema.validate($invalidUser)
ASSERT:C1129(Not:C34($invalidValidation.success); "Invalid user should fail validation")

TRACE:C157  // Success - all tests passed!

// ===============================================
// JSON Schema Draft 4 Enhanced Features Tests
// ===============================================

// Test 6: Enhanced JSONSchemaObjectNode with Draft 4 features
var $enhancedSchema : cs:C1710.JSONSchema:=cs:C1710.JSONSchema.new()
$enhancedSchema.title:="Enhanced User Schema"
$enhancedSchema.description:="Testing JSON Schema Draft 4 features"

// Basic properties with enhanced features
$enhancedSchema.addProperty("id"; cs:C1710.JSONSchemaIntegerNode.new())
$enhancedSchema.addProperty("username"; cs:C1710.JSONSchemaStringNode.new())
$enhancedSchema.addProperty("email"; cs:C1710.JSONSchemaStringNode.new())
$enhancedSchema.addProperty("age"; cs:C1710.JSONSchemaIntegerNode.new())
$enhancedSchema.addProperty("isActive"; cs:C1710.JSONSchemaBooleanNode.new())

// Set format for email
$enhancedSchema.setPropertyFormat("email"; "email")

// Add enum for user type
$enhancedSchema.addProperty("userType"; cs:C1710.JSONSchemaStringNode.new())
$enhancedSchema.addEnum("userType"; ["admin"; "user"; "guest"])

// Enhanced constraints
$enhancedSchema.setRequired(["id"; "username"; "email"])
$enhancedSchema.setMinProperties(3)
$enhancedSchema.setMaxProperties(15)
$enhancedSchema.setAdditionalProperties(False:C215)

// Test valid enhanced user
var $validEnhancedUser : Object:={\
id: 12345; \
username: "john_doe"; \
email: "john@example.com"; \
userType: "user"; \
isActive: True:C214\
}
var $enhancedResult : Object:=$enhancedSchema.validate($validEnhancedUser)
ASSERT:C1129($enhancedResult.success; "Valid enhanced user should pass validation")

// Test invalid enhanced user (missing required fields)
var $invalidEnhancedUser : Object:={username: "jane_doe"}
$enhancedResult:=$enhancedSchema.validate($invalidEnhancedUser)
ASSERT:C1129(Not:C34($enhancedResult.success); "Invalid enhanced user should fail validation")

// Test 7: Definitions support
var $schemaWithDefinitions : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $addressSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$addressSchema.addProperty("street"; cs:C1710.JSONSchemaStringNode.new())
$addressSchema.addProperty("city"; cs:C1710.JSONSchemaStringNode.new())
$addressSchema.addProperty("zipCode"; cs:C1710.JSONSchemaStringNode.new())
$addressSchema.setRequired(["street"; "city"])

$schemaWithDefinitions.addDefinition("address"; $addressSchema)
$schemaWithDefinitions.addProperty("homeAddress"; $addressSchema)
$schemaWithDefinitions.addProperty("workAddress"; $addressSchema)

// Test accessing definitions
var $addressDef : Object:=$schemaWithDefinitions.getDefinition("address")
ASSERT:C1129($addressDef#Null:C1517; "Address definition should exist")
ASSERT:C1129($addressDef.type="object"; "Address definition should be object type")

// Test 8: Pattern properties
var $patternSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $phoneSchema : cs:C1710.JSONSchemaStringNode:=cs:C1710.JSONSchemaStringNode.new()
$patternSchema.addPatternProperty("^phone"; $phoneSchema)

var $patternObject : Object:=$patternSchema.toObject()
ASSERT:C1129($patternObject.patternProperties#Null:C1517; "Pattern properties should be defined")

// Test 9: Dependencies
var $dependencySchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$dependencySchema.addProperty("name"; cs:C1710.JSONSchemaStringNode.new())
$dependencySchema.addProperty("creditCard"; cs:C1710.JSONSchemaStringNode.new())
$dependencySchema.addProperty("billingAddress"; cs:C1710.JSONSchemaStringNode.new())

// Property dependency: if creditCard exists, billingAddress is required
$dependencySchema.addDependency("creditCard"; ["billingAddress"])

var $depObject : Object:=$dependencySchema.toObject()
ASSERT:C1129($depObject.dependencies#Null:C1517; "Dependencies should be defined")

// Test 10: anyOf validation
var $anyOfSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $stringSchema : Object:={type: "string"}
var $numberSchema : Object:={type: "number"}
$anyOfSchema.setAnyOf([$stringSchema; $numberSchema])

var $anyOfObject : Object:=$anyOfSchema.toObject()
ASSERT:C1129($anyOfObject.anyOf#Null:C1517; "anyOf should be defined")
ASSERT:C1129($anyOfObject.anyOf.length=2; "anyOf should have 2 schemas")

// Test 11: oneOf validation
var $oneOfSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $schema1 : Object:={type: "object"; properties: {type: {enum: ["personal"]}}}
var $schema2 : Object:={type: "object"; properties: {type: {enum: ["business"]}}}
$oneOfSchema.setOneOf([$schema1; $schema2])

var $oneOfObject : Object:=$oneOfSchema.toObject()
ASSERT:C1129($oneOfObject.oneOf#Null:C1517; "oneOf should be defined")
ASSERT:C1129($oneOfObject.oneOf.length=2; "oneOf should have 2 schemas")

// Test 12: allOf validation
var $allOfSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $baseSchema : Object:={type: "object"; properties: {name: {type: "string"}}}
var $extendedSchema : Object:={type: "object"; properties: {age: {type: "integer"}}}
$allOfSchema.setAllOf([$baseSchema; $extendedSchema])

var $allOfObject : Object:=$allOfSchema.toObject()
ASSERT:C1129($allOfObject.allOf#Null:C1517; "allOf should be defined")
ASSERT:C1129($allOfObject.allOf.length=2; "allOf should have 2 schemas")

// Test 13: not validation
var $notSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $forbiddenSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$forbiddenSchema.addProperty("forbidden"; cs:C1710.JSONSchemaStringNode.new())
$notSchema.setNot($forbiddenSchema)

var $notObject : Object:=$notSchema.toObject()
ASSERT:C1129($notObject.not#Null:C1517; "not should be defined")

// Test 14: $ref usage
var $refSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$refSchema.setRef("#/definitions/user")

var $refObject : Object:=$refSchema.toObject()
ASSERT:C1129($refObject["$ref"]="#/definitions/user"; "$ref should be set correctly")

// Test 15: Complete Draft 4 schema generation
var $completeSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$completeSchema.title:="Complete User Profile Schema"
$completeSchema.description:="A comprehensive schema demonstrating Draft 4 features"

// Add comprehensive properties
$completeSchema.addProperty("id"; cs:C1710.JSONSchemaIntegerNode.new())
$completeSchema.addProperty("profile"; cs:C1710.JSONSchemaObjectNode.new())
$completeSchema.addProperty("tags"; cs:C1710.JSONSchemaArrayNode.new())

// Set all constraints
$completeSchema.setRequired(["id"])
$completeSchema.setMinProperties(1)
$completeSchema.setMaxProperties(20)
$completeSchema.setAdditionalProperties(False:C215)

// Build complete Draft 4 document
var $draft4Schema : Object:=$completeSchema.buildCompleteSchema()
ASSERT:C1129($draft4Schema["$schema"]="http://json-schema.org/draft-04/schema#"; "Should have Draft 4 schema identifier")
ASSERT:C1129($draft4Schema.type="object"; "Should be object type")
ASSERT:C1129($draft4Schema.title="Complete User Profile Schema"; "Should preserve title")

// Test 16: Clone functionality
var $clonedSchema : cs:C1710.JSONSchemaObjectNode:=$completeSchema.clone()
$clonedSchema.setMaxProperties(25)

var $originalMax : Integer:=$completeSchema.toObject().maxProperties
var $clonedMax : Integer:=$clonedSchema.toObject().maxProperties
ASSERT:C1129($originalMax=20; "Original schema should maintain original maxProperties")
ASSERT:C1129($clonedMax=25; "Cloned schema should have updated maxProperties")

// ===============================================
// Complete Example: Real-world JSON Schema Draft 4
// ===============================================

// Test 17: Comprehensive real-world example
var $realWorldSchema : cs:C1710.JSONSchema:=cs:C1710.JSONSchema.new()
$realWorldSchema.title:="E-commerce User Profile"
$realWorldSchema.description:="Complete user profile for e-commerce platform"

// User identification
$realWorldSchema.addProperty("userId"; cs:C1710.JSONSchemaIntegerNode.new())
$realWorldSchema.addProperty("email"; cs:C1710.JSONSchemaStringNode.new())
$realWorldSchema.addProperty("username"; cs:C1710.JSONSchemaStringNode.new())

// Set formats and constraints
$realWorldSchema.setPropertyFormat("email"; "email")
$realWorldSchema.addEnum("status"; ["active"; "inactive"; "suspended"])

// Contact preferences with anyOf
var $contactPreferences : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
var $emailContact : Object:={type: "object"; properties: {method: {enum: ["email"]}; address: {type: "string"; format: "email"}}}
var $phoneContact : Object:={type: "object"; properties: {method: {enum: ["phone"]}; number: {type: "string"; pattern: "^\\+?[1-9]\\d{1,14}$"}}}
$contactPreferences.setAnyOf([$emailContact; $phoneContact])
$realWorldSchema.addProperty("contactPreference"; $contactPreferences)

// Address using definitions
var $fullAddressSchema : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$fullAddressSchema.addProperty("street"; cs:C1710.JSONSchemaStringNode.new())
$fullAddressSchema.addProperty("city"; cs:C1710.JSONSchemaStringNode.new())
$fullAddressSchema.addProperty("state"; cs:C1710.JSONSchemaStringNode.new())
$fullAddressSchema.addProperty("zipCode"; cs:C1710.JSONSchemaStringNode.new())
$fullAddressSchema.addProperty("country"; cs:C1710.JSONSchemaStringNode.new())
$fullAddressSchema.setRequired(["street"; "city"; "country"])

$realWorldSchema.addDefinition("address"; $fullAddressSchema)

// Use address reference
var $shippingAddressRef : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$shippingAddressRef.setRef("#/definitions/address")
$realWorldSchema.addProperty("shippingAddress"; $shippingAddressRef)

var $billingAddressRef : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new()
$billingAddressRef.setRef("#/definitions/address")
$realWorldSchema.addProperty("billingAddress"; $billingAddressRef)

// Dependencies: if has shipping address, billing address is required
$realWorldSchema.addDependency("shippingAddress"; ["billingAddress"])

// Pattern properties for custom metadata
var $metadataStringSchema : cs:C1710.JSONSchemaStringNode:=cs:C1710.JSONSchemaStringNode.new()
$realWorldSchema.addPatternProperty("^custom_"; $metadataStringSchema)

// Final constraints
$realWorldSchema.setRequired(["userId"; "email"; "username"])
$realWorldSchema.setMinProperties(3)
$realWorldSchema.setMaxProperties(50)
$realWorldSchema.setAdditionalProperties(True:C214)

// Generate final schema
var $finalSchema : Object:=$realWorldSchema.buildCompleteSchema()

// Validate the structure
ASSERT:C1129($finalSchema["$schema"]="http://json-schema.org/draft-04/schema#"; "Should be Draft 4 compliant")
ASSERT:C1129($finalSchema.definitions#Null:C1517; "Should have definitions")
ASSERT:C1129($finalSchema.definitions.address#Null:C1517; "Should have address definition")
ASSERT:C1129($finalSchema.dependencies#Null:C1517; "Should have dependencies")
ASSERT:C1129($finalSchema.patternProperties#Null:C1517; "Should have pattern properties")

// Test with valid real-world data
var $validRealWorldUser : Object:={\
userId: 12345; \
email: "customer@example.com"; \
username: "customer123"; \
status: "active"; \
contactPreference: {\
method: "email"; \
address: "customer@example.com"\
}; \
shippingAddress: {\
street: "123 Commerce St"; \
city: "Tech City"; \
state: "CA"; \
zipCode: "90210"; \
country: "USA"\
}; \
billingAddress: {\
street: "123 Commerce St"; \
city: "Tech City"; \
state: "CA"; \
zipCode: "90210"; \
country: "USA"\
}; \
custom_preferences: "dark_theme"\
}

var $realWorldValidation : Object:=$realWorldSchema.validate($validRealWorldUser)
ASSERT:C1129($realWorldValidation.success; "Real-world valid user should pass validation")
