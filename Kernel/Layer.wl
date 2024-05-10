BeginPackage["ChristopherWolfram`GDALLink`Layer`"];

GDALLayerCreate

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]
Needs["ChristopherWolfram`GDALLink`Utilities`"]
Needs["ChristopherWolfram`GDALLink`Constants`"]
Needs["ChristopherWolfram`GDALLink`Feature`"]


(* GDALLayer object *)
DeclareObject[GDALLayer, {_GDALDataset, _OpaqueRawPointer}];

layer_GDALLayer["Dataset"] := layer[[1]]
layer_GDALLayer["RawLayer"] := layer[[2]]


cOGRLGetName := cOGRLGetName =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_GetName", {tOGRLayerH} -> "RawPointer"::["UnsignedInteger8"]];

layer_GDALLayer["Name"] := RawMemoryImport[cOGRLGetName[layer["RawLayer"]], "String"]


(* Features *)

cOGRLResetReading := cOGRLResetReading =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_ResetReading", {tOGRLayerH} -> "Void"];

layer_GDALLayer["ResetReading"] := cOGRLResetReading[layer["RawLayer"]]


cOGRLResetReading := cOGRLResetReading =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_ResetReading", {tOGRLayerH} -> "Void"];

layer_GDALLayer["ResetReading"] := cOGRLResetReading[layer["RawLayer"]]


cOGRLGetNextFeature := cOGRLGetNextFeature =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_GetNextFeature", {tOGRLayerH} -> tOGRFeatureH];

layer_GDALLayer["NextFeature"] := GDALFeatureCreate[layer, cOGRLGetNextFeature[layer["RawLayer"]]]

layer_GDALLayer["FeatureScan", f_] :=
	Module[{feature},
		layer["ResetReading"];
		While[feature = layer["NextFeature"]; feature =!= $Failed,
			f[feature]
		]
	]

layer_GDALLayer["FeatureMap", f_] :=
	Module[{bag},
		bag = Internal`Bag[];
		layer["FeatureScan", Internal`StuffBag[bag, f[#]]&];
		Internal`BagPart[bag, All]
	]


(* Fields *)

cOGRLGetLayerDefn := cOGRLGetLayerDefn =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_GetLayerDefn", {tOGRLayerH} -> tOGRFeatureDefnH];

layer_GDALLayer["RawLayerDefinition"] := cOGRLGetLayerDefn[layer["RawLayer"]]


cOGRFDGetFieldCount := cOGRFDGetFieldCount =
	ForeignFunctionLoad[$LibGDAL, "OGR_FD_GetFieldCount", {tOGRFeatureDefnH} -> "CInt"];

layer_GDALLayer["FieldCount"] := cOGRFDGetFieldCount[layer["RawLayerDefinition"]]


cOGRFDGetFieldDefn := cOGRFDGetFieldDefn =
	ForeignFunctionLoad[$LibGDAL, "OGR_FD_GetFieldDefn", {tOGRFeatureDefnH, "CInt"} -> tOGRFieldDefnH];

getFieldDefinition[layerDefinition_, i_] := cOGRFDGetFieldDefn[layerDefinition, i]

layer_GDALLayer["RawFieldDefinition", i_Integer] := getFieldDefinition[layer["RawLayerDefinition"], i]


(* Values of fields *)

cOGRFIsFieldSet := cOGRFIsFieldSet =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_IsFieldSet", {tOGRFeatureDefnH, "CInt"} -> "CInt"];

getFieldSet[layerDefinition_, i_] := cOGRFIsFieldSet[layerDefinition, i] === 1


cOGRFIsFieldNull := cOGRFIsFieldNull =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_IsFieldNull", {tOGRFeatureDefnH, "CInt"} -> "CInt"];

getFieldNull[layerDefinition_, i_] := cOGRFIsFieldNull[layerDefinition, i] === 1


cOGRFIsFieldSetAndNotNull := cOGRFIsFieldSetAndNotNull =
	ForeignFunctionLoad[$LibGDAL, "OGR_F_IsFieldSetAndNotNull", {tOGRFeatureDefnH, "CInt"} -> "CInt"];

getFieldSetAndNotNull[layerDefinition_, i_] := cOGRFIsFieldSetAndNotNull[layerDefinition, i] === 1


cOGRFldGetType := cOGRFldGetType =
	ForeignFunctionLoad[$LibGDAL, "OGR_Fld_GetType", {tOGRFieldDefnH} -> "CInt"];

getFieldType[fieldDefinition_] := cOGRFldGetType[fieldDefinition]

layer_GDALLayer["RawFieldType", i_Integer] :=
	With[{fieldDef = getFieldDefinition[layer["RawLayerDefinition"], i]},
		If[NullRawPointerQ[fieldDef], $Failed, getFieldType[fieldDef]]
	]


(* Constructors *)

DeclareFunction[GDALLayerCreate, iGDALLayerCreate, 2];

iGDALLayerCreate[dataset_GDALDataset, ptr_OpaqueRawPointer, opts_] :=
	If[NullRawPointerQ[ptr],
		$Failed,
		GDALLayer[dataset, ptr]
	]


End[];
EndPackage[];