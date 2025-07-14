Class extends JSONSchemaNode

property properties : Object
property required : Collection
property additionalProperties : Boolean
property minProperties : Integer
property maxProperties : Integer
property patternProperties : Object
property dependencies : Object
property anyOf : Collection
property oneOf : Collection
property allOf : Collection
property not : Object
//property $ref : Text
property definitions : Object

Class constructor($properties : Object)
	Super:C1705("object"; $properties)
	
Function addProperty($name : Text; $schemaNode : cs:C1710.JSONSchemaNode)
	If (This:C1470.properties=Null:C1517)
		This:C1470.properties:={}
	End if 
	This:C1470.properties[$name]:=$schemaNode.toObject()
	
Function setRequired($fieldNames : Collection)
	This:C1470.required:=$fieldNames.copy()
	
Function setAdditionalProperties($allowed : Boolean)
	This:C1470.additionalProperties:=$allowed
	
Function setMinProperties($min : Integer)
	This:C1470.minProperties:=$min
	
Function setMaxProperties($max : Integer)
	This:C1470.maxProperties:=$max
	
Function addPatternProperty($pattern : Text; $schemaNode : cs:C1710.JSONSchemaNode)
	If (This:C1470.patternProperties=Null:C1517)
		This:C1470.patternProperties:={}
	End if 
	This:C1470.patternProperties[$pattern]:=$schemaNode.toObject()
	
Function addDependency($propertyName : Text; $dependency : Variant)
	If (This:C1470.dependencies=Null:C1517)
		This:C1470.dependencies:={}
	End if 
	
	Case of 
		: (Value type:C1509($dependency)=Is collection:K8:32)
			// Property dependency - array of property names
			This:C1470.dependencies[$propertyName]:=$dependency
			
		: (Value type:C1509($dependency)=Is object:K8:27)
			// Schema dependency - object schema
			This:C1470.dependencies[$propertyName]:=$dependency
			
	End case 
	
Function setAnyOf($schemas : Collection)
	This:C1470.anyOf:=[]
	var $schema : Variant
	For each ($schema; $schemas)
		If (Value type:C1509($schema)=Is object:K8:27)
			This:C1470.anyOf.push($schema)
		End if 
	End for each 
	
Function setOneOf($schemas : Collection)
	This:C1470.oneOf:=[]
	var $schema : Variant
	For each ($schema; $schemas)
		If (Value type:C1509($schema)=Is object:K8:27)
			This:C1470.oneOf.push($schema)
		End if 
	End for each 
	
Function setAllOf($schemas : Collection)
	This:C1470.allOf:=[]
	var $schema : Variant
	For each ($schema; $schemas)
		If (Value type:C1509($schema)=Is object:K8:27)
			This:C1470.allOf.push($schema)
		End if 
	End for each 
	
Function setNot($schema : cs:C1710.JSONSchemaNode)
	This:C1470.not:=$schema.toObject()
	
Function setRef($reference : Text)
	This:C1470["$ref"]:=$reference
	
Function addDefinition($name : Text; $schemaNode : cs:C1710.JSONSchemaNode)
	If (This:C1470.definitions=Null:C1517)
		This:C1470.definitions:={}
	End if 
	This:C1470.definitions[$name]:=$schemaNode.toObject()
	
Function getDefinition($name : Text) : Object
	If (This:C1470.definitions#Null:C1517)
		return This:C1470.definitions[$name]
	End if 
	return Null:C1517
	
Function buildCompleteSchema() : cs:C1710.JSONSchema
	return cs:C1710.JSONSchema.new(This:C1470.toObject())
	
Function addEnum($propertyName : Text; $values : Collection)
	// Helper to add enum constraint to a property
	If (This:C1470.properties#Null:C1517) & (OB Is defined:C1231(This:C1470.properties; $propertyName))
		This:C1470.properties[$propertyName].enum:=$values.copy()
	End if 
	
Function setPropertyFormat($propertyName : Text; $format : Text)
	// Helper to set format for string properties (email, date-time, etc.)
	If (This:C1470.properties#Null:C1517) & (OB Is defined:C1231(This:C1470.properties; $propertyName))
		This:C1470.properties[$propertyName].format:=$format
	End if 
	
Function clone() : cs:C1710.JSONSchemaObjectNode
	// Create a deep copy of this schema node
	var $clonedProps : Object:=OB Copy:C1225(This:C1470.toObject())
	var $cloned : cs:C1710.JSONSchemaObjectNode:=cs:C1710.JSONSchemaObjectNode.new($clonedProps)
	return $cloned
	