BeginPackage["ChristopherWolfram`GDALLink`"];


$LibGDAL

GDALInitialize

GDALDataset
GDALDatasetImport

GDALLayer


Begin["`Private`"];


Needs["ChristopherWolfram`GDALLink`LibGDAL`"]
Needs["ChristopherWolfram`GDALLink`Initialization`"]
Needs["ChristopherWolfram`GDALLink`Dataset`"]
Needs["ChristopherWolfram`GDALLink`Layer`"]


End[];
EndPackage[];