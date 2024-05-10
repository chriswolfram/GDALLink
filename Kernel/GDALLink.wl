BeginPackage["ChristopherWolfram`GDALLink`"];


$LibGDAL

GDALInitialize

GDALDataset
GDALDatasetImport

GDALLayer

GDALFeature


Begin["`Private`"];


Needs["ChristopherWolfram`GDALLink`LibGDAL`"]
Needs["ChristopherWolfram`GDALLink`Initialization`"]
Needs["ChristopherWolfram`GDALLink`Dataset`"]
Needs["ChristopherWolfram`GDALLink`Layer`"]
Needs["ChristopherWolfram`GDALLink`Feature`"]


End[];
EndPackage[];