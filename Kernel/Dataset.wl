BeginPackage["ChristopherWolfram`GDALLink`Dataset`"];

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]
Needs["ChristopherWolfram`GDALLink`Utilities`"]
Needs["ChristopherWolfram`GDALLink`Constants`"]
Needs["ChristopherWolfram`GDALLink`Layer`"]


(* GDALDataset object *)
DeclareObject[GDALDataset, {_ManagedObject}];

dataset_GDALDataset["RawDataset"] := dataset[[1]]


cGDALDatasetGetLayerCount := GDALDatasetGetLayerCount =
	ForeignFunctionLoad[$LibGDAL, "GDALDatasetGetLayerCount", {tGDALDatasetH} -> "CInt"];

dataset_GDALDataset["LayerCount"] := cGDALDatasetGetLayerCount[dataset["RawDataset"]]


cGDALDatasetGetLayer := cGDALDatasetGetLayer =
	ForeignFunctionLoad[$LibGDAL, "GDALDatasetGetLayer", {tGDALDatasetH, "CInt"} -> tOGRLayerH];

cGDALDatasetGetLayerByName := cGDALDatasetGetLayerByName =
	ForeignFunctionLoad[$LibGDAL, "GDALDatasetGetLayerByName", {tGDALDatasetH, "RawPointer"::["UnsignedInteger8"]} -> tOGRLayerH];

dataset_GDALDataset["Layer", i_Integer] := GDALLayerCreate[dataset, cGDALDatasetGetLayer[dataset["RawDataset"], i-1]]
dataset_GDALDataset["Layer", name_?StringQ] := GDALLayerCreate[dataset, cGDALDatasetGetLayerByName[dataset["RawDataset"], name]]

dataset_GDALDataset["LayerList"] :=
	dataset["Layer", #] &/@ Range[dataset["LayerCount"]]

dataset_GDALDataset["LayerAssociation"] :=
	<|#["Name"] -> # &/@ dataset["LayerList"]|>

(* Constructors *)

cGDALOpenEx := cGDALOpenEx =
	ForeignFunctionLoad[$LibGDAL, "GDALOpenEx",
		{
		"RawPointer"::["UnsignedInteger8"],
		"CUnsignedInt",
		"RawPointer"::["UnsignedInteger8"],
		"RawPointer"::["UnsignedInteger8"],
		"RawPointer"::["UnsignedInteger8"]
		} -> tGDALDatasetH
	];

cGDALClose := cGDALClose = 
	ForeignFunctionLoad[$LibGDAL, "GDALClose", {tGDALDatasetH} -> "CInt"];


DeclareFunction[GDALDatasetImport, iGDALDatasetImport, 1];

iGDALDatasetImport[path_?StringQ, opts_] :=
	With[{res = cGDALOpenEx[
		path,
		$GDALConstants["GDAL_OF_VECTOR"],
		OpaqueRawPointer[0],
		OpaqueRawPointer[0],
		OpaqueRawPointer[0]
	]},
		If[NullRawPointerQ[res],
			$Failed,
			GDALDataset[CreateManagedObject[res, cGDALClose]]
		]
	]


End[];
EndPackage[];