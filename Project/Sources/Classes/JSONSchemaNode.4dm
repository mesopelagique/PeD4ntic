property type : Text
property title : Text
property description : Text

Class constructor($type : Text; $properties : Object)
	This:C1470.type:=$type
	If ($properties#Null:C1517)
		This:C1470._merge($properties)
	End if 
	
Function _merge($object : Object)
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
Function toObject() : Object
	// Convert the node to a plain object for JSON serialization
	var $result : Object:={}
	var $key : Text
	For each ($key; This:C1470)
		$result[$key]:=This:C1470[$key]
	End for each 
	return $result
	