BeginPackage["ChristopherWolfram`GDALLink`Feature`"];

GDALFeatureCreate

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]
Needs["ChristopherWolfram`GDALLink`Utilities`"]
Needs["ChristopherWolfram`GDALLink`Constants`"]


(* GDALFeature object *)
DeclareObject[GDALFeature, {_GDALLayer, _ManagedObject}];

feature_GDALFeature["Layer"] := feature[[1]]
feature_GDALFeature["RawFeature"] := feature[[2]]

cOGRFGetFieldAsString := cOGRFGetFieldAsString =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetFieldAsString", {tOGRFeatureH, "CInt"} -> "RawPointer"::["UnsignedInteger8"]];

feature_GDALFeature["FieldString", i_Integer] := RawMemoryImport[cOGRFGetFieldAsString[feature["RawFeature"], i-1], "String"]


cOGRFGetGeometryRef := cOGRFGetGeometryRef =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_GetGeometryRef", {tOGRFeatureH} -> tOGRGeometryH];

feature_GDALFeature["RawGeometry"] := cOGRFGetGeometryRef[feature["RawFeature"]]


cOGRGExportToWkt := cOGRGExportToWkt =
	ForeignFunctionLoad[$LibGDAL, "OGR_G_ExportToWkt", {tOGRFeatureH, "RawPointer"::["RawPointer"::["UnsignedInteger8"]]} -> "CInt"];

cVSIFree := cVSIFree =
	ForeignFunctionLoad[$LibGDAL, "VSIFree", {"OpaqueRawPointer"} -> "Void"];

feature_GDALFeature["GeometryWKT"] :=
	Module[{ptr, str, out},
		ptr = RawMemoryAllocate["RawPointer"::["UnsignedInteger8"]];
		cOGRGExportToWkt[feature["RawGeometry"], ptr];
		str = RawMemoryRead[ptr];
		out = RawMemoryImport[str, "String"];
		cVSIFree[str];
		out
	]


(* Constructors *)

cOGRFDestroy := cOGRFDestroy =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_Destroy", {tOGRFeatureH} -> "Void"];


DeclareFunction[GDALFeatureCreate, iGDALFeatureCreate, 2];

iGDALFeatureCreate[layer_GDALLayer, ptr_OpaqueRawPointer, opts_] :=
	If[NullRawPointerQ[ptr],
		$Failed,
		GDALFeature[layer, CreateManagedObject[ptr, cOGRFDestroy]]
	]


End[];
EndPackage[];