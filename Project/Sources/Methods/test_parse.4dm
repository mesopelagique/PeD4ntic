//%attributes = {}
var $schema : cs:C1710.JSONSchema
var $file : 4D:C1709.File
var $result : Object
For each ($file; Folder:C1567(fk database folder:K87:14).folder("Tests/Project/Sources/Classes").files())
	
	$schema:=cs:C1710.ClassParser.me.parseFile($file)
	LOG EVENT:C667(Into system standard outputs:K38:9; JSON Stringify:C1217($schema))
	
End for each 

$schema:=cs:C1710.DataClassParser.me.parse(ds:C1482.Table_1)
LOG EVENT:C667(Into system standard outputs:K38:9; JSON Stringify:C1217($schema))

var $entity:=ds:C1482.Table_1.new()
$entity.objectField:={}
$entity["Object field"]:={}
$entity["__GlobalStamp"]:=42
$entity["Date field"]:=Current date:C33  // FIX:  date? or ignore?
$result:=$schema.validate($entity)
ASSERT:C1129($result.success; JSON Stringify:C1217($result))