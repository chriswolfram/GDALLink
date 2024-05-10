BeginPackage["ChristopherWolfram`GDALLink`Constants`"];


$GDALConstants

(* Types *)
tGDALDatasetH = "OpaqueRawPointer";
tOGRLayerH = "OpaqueRawPointer";


Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]


$GDALConstants = <|
	"GDAL_OF_VECTOR" -> 4
|>;


End[];
EndPackage[];