singleton Class constructor
	
	// only if proj mode and interpreted
Function parseClassName($name : Text) : cs:C1710.JSONSchema
	This:C1470.parseFile(Folder:C1567(fk database folder:K87:14; *).file("Project/Sources/"+$name+".4dm"))
	
Function parseFile($classFile : 4D:C1709.File) : cs:C1710.JSONSchema
	return This:C1470.parseContent($classFile.getText("UTF-8"; Document with LF:K24:22); $classFile.name)
	
Function parseContent($classContent : Text; $className : Text) : cs:C1710.JSONSchema
	
	// Extract properties from class content
	var $properties : Collection
	$properties:=This:C1470.extractProperties($classContent)
	
	// Create JSON schema
	var $schema : cs:C1710.JSONSchema
	$schema:=cs:C1710.JSONSchema.new({\
		$schema: "http://json-schema.org/draft-07/schema#"; \
		title: $className; \
		type: "object"; \
		description: "JSON Schema for 4D class "+$className; \
		properties: {}; \
		additionalProperties: False:C215\
		})
	
	// Add properties to schema
	var $property : Object
	For each ($property; $properties)
		var $jsonSchemaType : Object
		$jsonSchemaType:=This:C1470.convertTypeToJsonSchema($property.type)
		$jsonSchemaType.description:=$property.name+" property of type "+$property.type
		$schema.properties[$property.name]:=$jsonSchemaType
	End for each 
	
	return $schema
	
	// Extract properties from 4D class content
Function extractProperties($content : Text) : Collection
	var $properties : Collection:=[]
	var $lines : Collection
	var $line : Text
	var $trimmedLine : Text
	var $propertyMatch : Object
	var $propertyName : Text
	var $propertyType : Text
	var $lineNumber : Integer
	
	$lines:=Split string:C1554($content; "\n")
	
	For ($lineNumber; 0; $lines.length-1)
		$line:=$lines[$lineNumber]
		$trimmedLine:=Trim:C1853($line)
		
		// Skip empty lines and comments
		If ($trimmedLine="") | (Position:C15("//"; $trimmedLine)=1) | (Position:C15("/*"; $trimmedLine)=1)
			continue
		End if 
		
		// Match property declarations: property name : Type or property name : Type := defaultValue
		$propertyMatch:=This:C1470.matchPropertyDeclaration($trimmedLine)
		
		If ($propertyMatch.isMatch)
			$propertyName:=$propertyMatch.name
			$propertyType:=$propertyMatch.type
			
			$properties.push({\
				name: $propertyName; \
				type: $propertyType; \
				line: $lineNumber+1; \
				originalLine: $line\
				})
		End if 
	End for 
	
	return $properties
	
	// Match property declaration using regex-like pattern
Function matchPropertyDeclaration($line : Text) : Object
	var $result : Object:={isMatch: False:C215; name: ""; type: ""}
	var $propertyPos : Integer
	var $colonPos : Integer
	var $assignPos : Integer
	var $beforeColon : Text
	var $afterColon : Text
	var $propertyName : Text
	var $propertyType : Text
	
	// Check if line starts with "property"
	$propertyPos:=Position:C15("property"; Lowercase:C14($line))
	If ($propertyPos#1)
		return $result
	End if 
	
	// Find colon position
	$colonPos:=Position:C15(":"; $line)
	If ($colonPos=0)
		return $result
	End if 
	
	// Extract parts
	$beforeColon:=Substring:C12($line; 9; $colonPos-9)  // After "property"
	$afterColon:=Substring:C12($line; $colonPos+1)
	
	$propertyName:=Trim:C1853($beforeColon)
	$propertyType:=Trim:C1853($afterColon)
	
	// Handle default values (remove := part)
	$assignPos:=Position:C15(":="; $propertyType)
	If ($assignPos>0)
		$propertyType:=Trim:C1853(Substring:C12($propertyType; 1; $assignPos-1))
	End if 
	
	// Validate property name
	If ($propertyName#"") & ($propertyType#"")
		$result.isMatch:=True:C214
		$result.name:=$propertyName
		$result.type:=$propertyType
	End if 
	
	return $result
	
	// Convert 4D type to JSON Schema type
Function convertTypeToJsonSchema($fourDType : Text) : Object
	var $result : Object
	var $lowerType : Text
	var $classMatch : Object
	
	$fourDType:=Trim:C1853($fourDType)
	$lowerType:=Lowercase:C14($fourDType)
	
	// Handle cs. prefixed class references
	If (Position:C15("cs."; $fourDType)=1)
		var $referencedClass : Text:=Substring:C12($fourDType; 4)
		$result:={\
			type: "object"; \
			$ref: "#/definitions/"+$referencedClass; \
			description: "Reference to "+$referencedClass+" class"\
			}
		return $result
	End if 
	
	// Handle collection types
	If (Position:C15("collection"; $lowerType)>0)
		If (Position:C15("cs."; $fourDType)>0)
			// Collection of custom class - extract class name
			$classMatch:=This:C1470.extractClassFromCollection($fourDType)
			If ($classMatch.found)
				$result:={\
					type: "array"; \
					items: {$ref: "#/definitions/"+$classMatch.className}\
					}
			Else 
				$result:={\
					type: "array"; \
					items: {type: "object"}\
					}
			End if 
		Else 
			$result:={\
				type: "array"; \
				items: {type: "object"}\
				}
		End if 
		return $result
	End if 
	
	// Map 4D basic types to JSON Schema types
	Case of 
		: ($lowerType="text") | ($lowerType="string")
			$result:={type: "string"}
		: ($lowerType="integer")
			$result:={type: "integer"}
		: ($lowerType="real") | ($lowerType="number")
			$result:={type: "number"}
		: ($lowerType="boolean") | ($lowerType="bool")
			$result:={type: "boolean"}
		: ($lowerType="date")
			$result:={type: "string"; format: "date"}
		: ($lowerType="time")
			$result:={type: "string"; format: "time"}
		: ($lowerType="object")
			$result:={type: "object"}
		: ($lowerType="variant")
			$result:={\
				anyOf: [\
				{type: "string"}; \
				{type: "number"}; \
				{type: "boolean"}; \
				{type: "object"}; \
				{type: "array"}\
				]\
				}
		: ($lowerType="blob")
			$result:={type: "string"; contentEncoding: "base64"}
		: ($lowerType="picture")
			$result:={type: "string"; contentEncoding: "base64"}
		Else 
			$result:={\
				type: "object"; \
				description: "Unknown 4D type: "+$fourDType\
				}
	End case 
	
	return $result
	
	// Extract class name from collection type comment
Function extractClassFromCollection($typeString : Text) : Object
	var $result : Object:={found: False:C215; className: ""}
	var $csPos : Integer
	var $classStart : Integer
	var $classEnd : Integer
	var $className : Text
	
	$csPos:=Position:C15("cs."; $typeString)
	If ($csPos>0)
		$classStart:=$csPos+3
		$classEnd:=$classStart
		
		// Find end of class name (space, ), or end of string)
		While ($classEnd<=Length:C16($typeString))
			var $char : Text:=Substring:C12($typeString; $classEnd; 1)
			If ($char=" ") | ($char=")") | ($char="") | ($char=">")
				break
			End if 
			$classEnd:=$classEnd+1
		End while 
		
		$className:=Substring:C12($typeString; $classStart; $classEnd-$classStart)
		If ($className#"")
			$result.found:=True:C214
			$result.className:=$className
		End if 
	End if 
	
	return $result
	