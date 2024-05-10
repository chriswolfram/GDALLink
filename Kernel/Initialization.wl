BeginPackage["ChristopherWolfram`GDALLink`Initialization`"];

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]
Needs["ChristopherWolfram`GDALLink`Utilities`"]


cGDALAllRegister := cGDALAllRegister =
	ForeignFunctionLoad[$LibGDAL, "GDALAllRegister", {} -> "Void"];


DeclareFunction[GDALInitialize, iGDALInitialize, 0];

iGDALInitialize[opts_] := cGDALAllRegister[]


End[];
EndPackage[];