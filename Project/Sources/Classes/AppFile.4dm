singleton Class constructor
	
Function _appResources() : 4D:C1709.Folder
	
	var $path : Text
	$path:=Application file:C491
	
	Case of 
		: (Is Windows:C1573)
			
			return File:C1566($path; fk platform path:K87:2).parent.folder("Resources")
			
		: (Is macOS:C1572)
			
			return Folder:C1567($path; fk platform path:K87:2).folder("Contents/Resources")
			
	End case 
	
	return Null:C1517  // will throw
	
Function formsSchema() : cs:C1710.JSONSchema
	return cs:C1710.JSONSchema.new(This:C1470._appResources().file("formsSchema.json"))
	
Function themeSchema() : cs:C1710.JSONSchema
	return cs:C1710.JSONSchema.new(This:C1470._appResources().file("JSONSchemas/themeSchema.json"))