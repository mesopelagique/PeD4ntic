singleton Class constructor
	
	// Parse a ds.EntityName object and convert it to JSON schema
Function parse($entity : 4D:C1709.DataClass) : cs:C1710.JSONSchema
	
	
	// Get table name from entity
	var $tableName : Text
	$tableName:=$entity.getInfo().name
	
	// Create JSON schema structure
	var $schema : cs:C1710.JSONSchema
	$schema:=cs:C1710.JSONSchema.new({\
		$schema: "http://json-schema.org/draft-04/schema#"; \
		title: $tableName; \
		type: "object"; \
		description: "JSON Schema for 4D entity "+$tableName; \
		properties: {}\
		})
	
	// Parse each field from the entity definition
	var $required : Collection:=[]
	var $field : Object
	var $hasExcludedFields : Boolean:=False:C215
	
	For each ($field; This:C1470.getEntityFields($entity))
		// Skip picture and blob fields as they cannot be converted to JSON schema
		If (This:C1470.isConvertibleField($field))
			var $fieldSchema : Object
			$fieldSchema:=This:C1470.convertFieldToJsonSchema($field)
			$schema.properties[$field.name]:=$fieldSchema
			
			// Add to required array if mandatory
			If ($field.mandatory)
				$required.push($field.name)
			End if 
		Else 
			// Mark that we have excluded fields
			$hasExcludedFields:=True:C214
		End if 
	End for each 
	
	// Set additionalProperties based on whether we excluded any fields
	$schema.additionalProperties:=$hasExcludedFields
	
	// Add required fields if any
	If ($required.length>0)
		$schema.required:=$required
	End if 
	
	return $schema
	
	
	// Extract field information from entity
Function getEntityFields($entity : Object) : Collection
	var $fields : Collection:=[]
	var $field : Object
	var $fieldInfo : Object
	var $key : Text
	
	// If entity has direct field definitions (like your JSON example)
	If ($entity.fields#Null:C1517)
		return $entity.fields
	End if 
	
	// Try to get fields from entity structure
	For each ($key; $entity)
		$field:=$entity[$key]
		
		// Check if this is a field definition object
		If (This:C1470.isFieldDefinition($field))
			$fieldInfo:=This:C1470.normalizeFieldInfo($field)
			$fieldInfo.name:=$key
			$fields.push($fieldInfo)
		End if 
	End for each 
	
	return $fields
	
	// Check if object is a field definition
Function isFieldDefinition($object : Object) : Boolean
	// Check for common field properties
	return ($object.kind#Null:C1517) | ($object.type#Null:C1517) | ($object.fieldType#Null:C1517) | ($object.fieldNumber#Null:C1517)
	
	// Check if field type can be converted to JSON schema
Function isConvertibleField($field : Object) : Boolean
	var $fieldType : Text
	$fieldType:=$field.type
	
	// Exclude picture and blob fields
	Case of 
		: ($fieldType="blob")
			return False:C215
		: ($fieldType="image")
			return False:C215
		: ($fieldType="picture")
			return False:C215
		Else 
			return True:C214
	End case 
	
	// Normalize field information to standard format
Function normalizeFieldInfo($field : Object) : Object
	var $normalized : Object:={}
	
	// Copy all properties from original field
	For each ($key; $field)
		$normalized[$key]:=$field[$key]
	End for each 
	
	// Ensure required properties have defaults
	If ($normalized.kind=Null:C1517)
		$normalized.kind:="storage"
	End if 
	
	If ($normalized.exposed=Null:C1517)
		$normalized.exposed:=True:C214
	End if 
	
	If ($normalized.mandatory=Null:C1517)
		$normalized.mandatory:=False:C215
	End if 
	
	If ($normalized.unique=Null:C1517)
		$normalized.unique:=False:C215
	End if 
	
	If ($normalized.indexed=Null:C1517)
		$normalized.indexed:=False:C215
	End if 
	
	If ($normalized.autoFilled=Null:C1517)
		$normalized.autoFilled:=False:C215
	End if 
	
	return $normalized
	
	// Convert field definition to JSON schema property
Function convertFieldToJsonSchema($field : Object) : Object
	var $jsonSchema : Object:={}
	var $type : Text
	var $format : Text
	
	// Get the field type
	$type:=This:C1470.mapFieldTypeToJsonType($field.type)
	$jsonSchema.type:=$type
	If ($field.type="date")
		$jsonSchema.format:="date"
	End if 
	
	// Add format if applicable
	$format:=This:C1470.getJsonFormat($field.type)
	If ($format#"")
		$jsonSchema.format:=$format
	End if 
	
	// Add description
	$jsonSchema.description:=$field.name+" field"
	If ($field.mandatory)
		$jsonSchema.description:=$jsonSchema.description+" (mandatory)"
	End if 
	
	// Add constraints based on field properties
	If ($field.unique)
		$jsonSchema.description:=$jsonSchema.description+" (unique)"
	End if 
	
	If ($field.indexed)
		$jsonSchema.description:=$jsonSchema.description+" (indexed)"
	End if 
	
	If ($field.autoFilled)
		$jsonSchema.description:=$jsonSchema.description+" (auto-filled)"
	End if 
	
	// Add type-specific constraints
	Case of 
		: ($type="string")
			// Add string constraints if available
			If ($field.maxLength#Null:C1517)
				$jsonSchema.maxLength:=$field.maxLength
			End if 
			
		: ($type="number") | ($type="integer")
			// Add numeric constraints if available
			If ($field.minimum#Null:C1517)
				$jsonSchema.minimum:=$field.minimum
			End if 
			If ($field.maximum#Null:C1517)
				$jsonSchema.maximum:=$field.maximum
			End if 
			
	End case 
	
	return $jsonSchema
	
	// Map 4D field type to JSON schema type
Function mapFieldTypeToJsonType($fieldType : Text) : Text
	Case of 
		: ($fieldType="string")
			return "string"
		: ($fieldType="number")
			return "number"
		: ($fieldType="bool") | ($fieldType="boolean")
			return "boolean"
		: ($fieldType="date")
			return "string"
		: ($fieldType="time")
			return "string"
		: ($fieldType="object")
			return "object"
		Else 
			return "string"  // Default fallback
	End case 
	
	// Get JSON format for specific field types
Function getJsonFormat($fieldType : Text) : Text
	Case of 
		: ($fieldType="date")
			return "date"
		: ($fieldType="time")
			return "time"
		Else 
			return ""
	End case 
	