BeginPackage["ChristopherWolfram`GDALLink`Feature`"];

GDALFeatureCreate
GetFieldDefinitionType
GetFieldDefinitionName

RawFeatureDestroy
RawFeatureGeometry
RawGeometryWKT
RawGeometryWKB

$FieldTypeFunctions
$DefaultFieldType

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]
Needs["ChristopherWolfram`GDALLink`Utilities`"]
Needs["ChristopherWolfram`GDALLink`Constants`"]


(* GDALFeature object *)
DeclareObject[GDALFeature, {_GDALLayer, _ManagedObject}];

feature_GDALFeature["Layer"] := feature[[1]]
feature_GDALFeature["RawFeature"] := feature[[2]]

(* Fields *)

cOGRFGetFieldCount := cOGRFGetFieldCount =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldCount", {tOGRFeatureH} -> "CInt"];

feature_GDALFeature["FieldCount"] := cOGRFGetFieldCount[feature["RawFeature"]]


cOGRFGetFieldDefnRef := cOGRFGetFieldDefnRef =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldDefnRef", {tOGRFeatureH, "CInt"} -> "RawPointer"::["UnsignedInteger8"]];

feature_GDALFeature["RawFieldDefinition", i_Integer] := cOGRFGetFieldDefnRef[feature["RawFeature"], i-1]


cOGRFldGetType := cOGRFldGetType =
	ForeignFunctionLoad[$LibGDAL, "OGR_Fld_GetType", {tOGRFieldDefnH} -> "CInt"];

GetFieldDefinitionType[fieldDefinition_] := cOGRFldGetType[fieldDefinition]

feature_GDALFeature["RawFieldType", i_Integer] :=
	With[{fieldDef = feature["RawFieldDefinition", i]},
		If[NullRawPointerQ[fieldDef], $Failed, GetFieldDefinitionType[fieldDef]]
	]


cOGRFldGetNameRef := cOGRFldGetNameRef =
	ForeignFunctionLoad[$LibGDAL, "OGR_Fld_GetNameRef", {tOGRFieldDefnH} -> "RawPointer"::["UnsignedInteger8"]];

GetFieldDefinitionName[fieldDefinition_] := RawMemoryImport[cOGRFldGetNameRef[fieldDefinition], "String"]

feature_GDALFeature["FieldNames", i_Integer] := GetFieldDefinitionName@feature["RawFieldDefinition", i]
feature_GDALFeature["FieldNames"] := feature["FieldNames", #]&/@Range[feature["FieldCount"]]


(* Missing data *)
cOGRFIsFieldSet := cOGRFIsFieldSet =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_IsFieldSet", {tOGRFeatureH, "CInt"} -> "CInt"];

feature_GDALFeature["FieldSetQ", i_Integer] := cOGRFIsFieldSet[feature["RawFeature"], i-1] === 1

cOGRFIsFieldNull := cOGRFIsFieldNull =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_IsFieldNull", {tOGRFeatureH, "CInt"} -> "CInt"];

feature_GDALFeature["FieldNullQ", i_Integer] := cOGRFIsFieldNull[feature["RawFeature"], i-1] === 1

cOGRFIsFieldSetAndNotNull := cOGRFIsFieldSetAndNotNull =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_IsFieldSetAndNotNull", {tOGRFeatureH, "CInt"} -> "CInt"];

feature_GDALFeature["FieldSetNotNullQ", i_Integer] := cOGRFIsFieldSetAndNotNull[feature["RawFeature"], i-1] === 1


(* Getting values *)
cOGRFGetFieldAsInteger := cOGRFGetFieldAsInteger =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldAsInteger", {tOGRFeatureH, "CInt"} -> "CInt"];

feature_GDALFeature["FieldInteger", i_Integer] := cOGRFGetFieldAsInteger[feature["RawFeature"], i-1]


cOGRFGetFieldAsInteger64 := cOGRFGetFieldAsInteger64 =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldAsInteger64", {tOGRFeatureH, "CInt"} -> "Integer64"(*Should really be CLongLong*)];

feature_GDALFeature["FieldInteger64", i_Integer] := cOGRFGetFieldAsInteger64[feature["RawFeature"], i-1]


cOGRFGetFieldAsDouble := cOGRFGetFieldAsDouble =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldAsDouble", {tOGRFeatureH, "CInt"} -> "CDouble"];

feature_GDALFeature["FieldDouble", i_Integer] := cOGRFGetFieldAsDouble[feature["RawFeature"], i-1]


cOGRFGetFieldAsString := cOGRFGetFieldAsString =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldAsString", {tOGRFeatureH, "CInt"} -> "RawPointer"::["UnsignedInteger8"]];

feature_GDALFeature["FieldString", i_Integer] := RawMemoryImport[cOGRFGetFieldAsString[feature["RawFeature"], i-1], "String"]


(*
From documentation:

OGRFieldType {
  OFTInteger = 0 , OFTIntegerList = 1 , OFTReal = 2 , OFTRealList = 3 ,
  OFTString = 4 , OFTStringList = 5 , OFTWideString = 6 , OFTWideStringList = 7 ,
  OFTBinary = 8 , OFTDate = 9 , OFTTime = 10 , OFTDateTime = 11 ,
  OFTInteger64 = 12 , OFTInteger64List = 13 , OFTMaxType = 13
}
*)
$FieldTypeFunctions := $FieldTypeFunctions = <|
	0 -> cOGRFGetFieldAsInteger,
	3 -> cOGRFGetFieldAsDouble,
	4 -> (RawMemoryImport[cOGRFGetFieldAsString[#1,#2], "String"]&),
	12 -> cOGRFGetFieldAsInteger64
|>;
$DefaultFieldType = 12;

feature_GDALFeature["Field", i_Integer] :=
	Lookup[
		$FieldTypeFunctions,
		feature["RawFieldType", i],
		$FieldTypeFunctions[$DefaultFieldType]
	][feature["RawFeature"],i-1]

(* Switch[feature["RawFieldType", i],
	0,  feature["FieldInteger", i],
	3,  feature["FieldDouble", i],
	4,  feature["FieldString", i],
	12, feature["FieldInteger64", i],
	_,  feature["FieldString", i]
] *)

feature_GDALFeature["FieldList"] :=
	feature["Field", #]&/@Range[feature["FieldCount"]]

feature_GDALFeature["FieldAssociation"] :=
	<|feature["FieldName", #] -> feature["Field", #]&/@Range[feature["FieldCount"]]|>


(* Geometry *)

cOGRFGetGeometryRef := cOGRFGetGeometryRef =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetGeometryRef", {tOGRFeatureH} -> tOGRGeometryH];

RawFeatureGeometry[rawFeature_] := cOGRFGetGeometryRef[rawFeature]

feature_GDALFeature["RawGeometry"] := RawFeatureGeometry[feature["RawFeature"]]


cOGRGExportToWkt := cOGRGExportToWkt =
	ForeignFunctionLoad[$LibGDAL, "OGR_G_ExportToWkt", {tOGRGeometryH, "RawPointer"::["RawPointer"::["UnsignedInteger8"]]} -> "CInt"];

cVSIFree := cVSIFree =
	ForeignFunctionLoad[$LibGDAL, "VSIFree", {"OpaqueRawPointer"} -> "Void"];

RawGeometryWKT[rawGeometry_, ptr_] :=
	Module[{str, out},
		cOGRGExportToWkt[rawGeometry, ptr];
		str = RawMemoryRead[ptr];
		out = RawMemoryImport[str, "String"];
		cVSIFree[str];
		out
	]
RawGeometryWKT[rawGeometry_] := RawGeometryWKT[rawGeometry, RawMemoryAllocate["UnsignedInteger8"]]

feature_GDALFeature["GeometryWKT"] := RawGeometryWKT[feature["RawGeometry"]]


cOGRGWkbSize := cOGRGWkbSize =
	ForeignFunctionLoad[$LibGDAL, "OGR_G_WkbSize", {tOGRGeometryH} -> "CInt"];

cOGRGExportToWkb := cOGRGExportToWkb =
	ForeignFunctionLoad[$LibGDAL, "OGR_G_ExportToWkb", {tOGRGeometryH, "CInt", "RawPointer"::["UnsignedInteger8"]} -> "CInt"];

RawGeometryWKB[rawGeometry_, byteOrder_:0] :=
	Module[{size, ptr},
		size = cOGRGWkbSize[rawGeometry];
		ptr = RawMemoryAllocate["UnsignedInteger8", size];
		cOGRGExportToWkb[rawGeometry, byteOrder, ptr];
		RawMemoryImport[ptr, {"ByteArray", size}]
	]

feature_GDALFeature["GeometryWKB", byteOrder_:0] := RawGeometryWKB[feature["RawGeometry"], byteOrder]


(* Constructors *)

cOGRFDestroy := cOGRFDestroy =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_Destroy", {tOGRFeatureH} -> "Void"];

RawFeatureDestroy[rawFeature_] := cOGRFDestroy[rawFeature]


DeclareFunction[GDALFeatureCreate, iGDALFeatureCreate, 2];

iGDALFeatureCreate[layer_GDALLayer, ptr_OpaqueRawPointer, opts_] :=
	If[NullRawPointerQ[ptr],
		$Failed,
		GDALFeature[layer, CreateManagedObject[ptr, RawFeatureDestroy]]
	]


End[];
EndPackage[];