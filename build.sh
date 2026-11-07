#!/bin/bash
# Build KSP_EngineAnalyzer.dll from Source/2.2.0.cs and Source/AssemblyInfo.cs against the installed game's mscorlib, Unity
# and Assembly-CSharp into GameData/EngineAnalyzer/, where upstream keeps the built DLL. Needs
# Roslyn (C# 7 tuples; mono's mcs can't): the .NET SDK's csc.dll, run with dotnet. --install also copies
# GameData/EngineAnalyzer into the game (KSP loads it at the next start); the stock build is
# normally installed with CKAN from the local repo (~/tmp/ksp/tools/ckan) instead.
set -e
HERE="$(dirname "$(readlink -f "$0")")"
K="${KSP:-$HOME/.local/share/Steam/steamapps/common/Kerbal Space Program}"
M="$K/KSP_Data/Managed"
OUT="${OUT:-$HERE/GameData/EngineAnalyzer/KSP_EngineAnalyzer.dll}"
DOTNET="${DOTNET:-$HOME/.dotnet/dotnet}"
CSC="${CSC:-$(ls -d "$HOME"/.dotnet/sdk/*/Roslyn/bincore/csc.dll | sort -V | tail -1)}"
"$DOTNET" "$CSC" -nologo -noconfig -nostdlib+ -target:library -optimize+ -deterministic \
    -langversion:7.3 -nowarn:0168,0219,0414 -out:"$OUT" \
    -r:"$M/mscorlib.dll" -r:"$M/System.dll" -r:"$M/System.Core.dll" \
    -r:"$M/Assembly-CSharp.dll" -r:"$M/UnityEngine.dll" -r:"$M/UnityEngine.CoreModule.dll" \
    -r:"$M/UnityEngine.IMGUIModule.dll" -r:"$M/UnityEngine.UI.dll" -r:"$M/UnityEngine.AnimationModule.dll" \
    "$HERE/Source/2.2.0.cs" "$HERE/Source/AssemblyInfo.cs"
echo "Built $OUT"
[ "$1" = "--install" ] || exit 0
rm -rf "$K/GameData/EngineAnalyzer"
cp -r "$HERE/GameData/EngineAnalyzer" "$K/GameData/"
echo "Installed $K/GameData/EngineAnalyzer (restart KSP to load it)"
