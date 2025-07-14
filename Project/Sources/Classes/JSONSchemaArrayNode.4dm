Class extends JSONSchemaNode

property items : Object
property minItems : Integer
property maxItems : Integer
property uniqueItems : Boolean

Class constructor($properties : Object)
	Super:C1705("array"; $properties)

Function setItemSchema($itemSchema : cs:C1710.JSONSchemaNode)
	This:C1470.items:=$itemSchema.toObject()
