BeginPackage["ChristopherWolfram`GDALLink`LibGDAL`"];

Begin["`Private`"];

Needs["ChristopherWolfram`GDALLink`"]


(* TODO: Temporary hard-coded install path *)
$LibGDAL := $LlamaInstallPath = FileNameJoin[{Last@FileNames["*", "/opt/homebrew/Cellar/gdal/"], "lib", "libgdal.dylib"}];


End[];
EndPackage[];