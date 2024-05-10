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