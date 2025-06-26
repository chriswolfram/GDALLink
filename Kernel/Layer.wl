BeginPackage["ChristopherWolfram`GDALLink`Layer`"];

GDALLayerCreate

Begin["`Private`"];

Needs["GEOSLink`"]

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

layer_GDALLayer["Features"] := layer["FeatureMap", Identity]


(* Fields *)

cOGRLGetLayerDefn := cOGRLGetLayerDefn =
	ForeignFunctionLoad[$LibGDAL, "OGR_L_GetLayerDefn", {tOGRLayerH} -> tOGRFeatureDefnH];

layer_GDALLayer["RawLayerDefinition"] := cOGRLGetLayerDefn[layer["RawLayer"]]


cOGRFDGetFieldCount := cOGRFDGetFieldCount =
	ForeignFunctionLoad[$LibGDAL, "OGR_FD_GetFieldCount", {tOGRFeatureDefnH} -> "CInt"];

layer_GDALLayer["FieldCount"] := cOGRFDGetFieldCount[layer["RawLayerDefinition"]]


cOGRFDGetFieldDefn := cOGRFDGetFieldDefn =
	ForeignFunctionLoad[$LibGDAL, "OGR_FD_GetFieldDefn", {tOGRFeatureDefnH, "CInt"} -> tOGRFieldDefnH];

getFieldDefinition[layerDefinition_, i_] := cOGRFDGetFieldDefn[layerDefinition, i-1]

layer_GDALLayer["RawFieldDefinition", i_Integer] := getFieldDefinition[layer["RawLayerDefinition"], i]


(* Values of fields *)

layer_GDALLayer["RawFieldType", i_Integer] :=
	With[{fieldDef = getFieldDefinition[layer["RawLayerDefinition"], i]},
		If[NullRawPointerQ[fieldDef], $Failed, GetFieldDefinitionType[fieldDef]]
	]

layer_GDALLayer["FieldNames", i_Integer] :=
	With[{fieldDef = getFieldDefinition[layer["RawLayerDefinition"], i]},
		If[NullRawPointerQ[fieldDef], $Failed, GetFieldDefinitionName[fieldDef]]
	]

layer_GDALLayer["FieldNames"] := layer["FieldNames", #]&/@Range[layer["FieldCount"]] 


layer_GDALLayer["FieldList"] :=
	Module[{cols, colTypes, colFuns, rawLayer, rawFeature, bag},
		cols = Range[layer["FieldCount"]];
		rawLayer = layer["RawLayer"];

		colTypes = layer["RawFieldType", #]&/@cols;
		colFuns = Lookup[$FieldTypeFunctions, colTypes, $FieldTypeFunctions[$DefaultFieldType]];

		layer["ResetReading"];
		bag = Internal`Bag[];
		While[rawFeature = cOGRLGetNextFeature[rawLayer]; !NullRawPointerQ[rawFeature],
			Internal`StuffBag[bag,
				MapThread[#1[rawFeature,#2]&, {colFuns, cols-1}]
			];
			RawFeatureDestroy[rawFeature]
		];
		Internal`BagPart[bag, All]
	]

layer_GDALLayer["FieldAssociation"] := AssociationThread[layer["FieldNames"], Transpose@layer["FieldList"]]
layer_GDALLayer["FieldTabular"] := ToTabular[layer["FieldAssociation"], "Columns"]


(* Geometry *)

layer_GDALLayer["GeometryList"] :=
	Module[{rawLayer, rawFeature, bag},
		rawLayer = layer["RawLayer"];

		layer["ResetReading"];
		bag = Internal`Bag[];
		While[rawFeature = cOGRLGetNextFeature[rawLayer]; !NullRawPointerQ[rawFeature],
			Internal`StuffBag[bag,
				FromGEOS@FromWKB@RawGeometryWKB[RawFeatureGeometry[rawFeature]]
			];
			RawFeatureDestroy[rawFeature]
		];
		Internal`BagPart[bag, All]
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