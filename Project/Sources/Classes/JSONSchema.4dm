Class extends JSONSchemaObjectNode

Class constructor($object : Object)
	// Initialize as object type
	If (OB Instance of:C1731($object; 4D:C1709.File))
		Super:C1705(JSON Parse:C1218($object.getText()))
	Else 
		Super:C1705($object)
	End if 
	
	// Set default schema version
	This:C1470["$schema"]:="http://json-schema.org/draft-04/schema#"
	
Function validate($object : Object) : Object
	return JSON Validate:C1456($object; This:C1470)
	
Function save($file : 4D:C1709.File)
	$file.setText(JSON Stringify:C1217(This:C1470; *))