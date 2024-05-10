BeginPackage["ChristopherWolfram`GDALLink`LibGDAL`"];

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]


(* TODO: Temporary hard-coded install path *)
$LibGDAL := $LlamaInstallPath = "/opt/homebrew/Cellar/gdal/3.8.5_2/lib/libgdal.dylib";


End[];
EndPackage[];