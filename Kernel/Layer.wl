BeginPackage["ChristopherWolfram`GDALLink`Layer`"];

GDALLayerCreate

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]
Needs["ChristopherWolfram`GDALLink`Utilities`"]
Needs["ChristopherWolfram`GDALLink`Constants`"]


(* GDALLayer object *)
DeclareObject[GDALLayer, {_GDALDataset, _OpaqueRawPointer}];

layer_GDALLayer["Dataset"] := layer[[1]]
layer_GDALLayer["RawLayer"] := layer[[2]]


cOGRLGetName := cOGRLGetName =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_GetName", {tOGRLayerH} -> "RawPointer"::["UnsignedInteger8"]];

layer_GDALLayer["Name"] := RawMemoryImport[cOGRLGetName[layer["RawLayer"]], "String"]


(* Constructors *)

DeclareFunction[GDALLayerCreate, iGDALLayerCreate, 2];

iGDALLayerCreate[dataset_GDALDataset, ptr_OpaqueRawPointer, opts_] :=
	If[NullRawPointerQ[ptr],
		$Failed,
		GDALLayer[dataset, ptr]
	]


End[];
EndPackage[];