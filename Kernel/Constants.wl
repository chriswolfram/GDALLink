BeginPackage["ChristopherWolfram`GDALLink`Constants`"];


$GDALConstants

(* Types *)
tGDALDatasetH = "OpaqueRawPointer";
tOGRLayerH = "OpaqueRawPointer";
tOGRFeatureH = "OpaqueRawPointer";
tOGRFeatureDefnH = "OpaqueRawPointer";
tOGRFieldDefnH = "OpaqueRawPointer";
tOGRGeometryH = "OpaqueRawPointer";


Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]


$GDALConstants = <|
	"GDAL_OF_VECTOR" -> 4
|>;


End[];
EndPackage[];