::@echo off

:: Change into the directory where this script is running
pushd %~dp0

:: Set repo_root to the root folder of the repository (i.e. where the .git metadata folder is located)
for /F "tokens=*" %%g in ('git rev-parse --show-toplevel') do (set repo_root=%%g)
set repo_root=%repo_root:/=\%
pushd %repo_root%

:: Set manual_dir variable to the full path where manually packaged artifacts should be placed
set output_dir=%repo_root%\.veracode\output
set manual_dir=%output_dir%\manual

:: Clean up and create output directories
if exist %output_dir% rd /q /s %output_dir%
mkdir %manual_dir%

:: Create settings targets file
set targets_file=%output_dir%\VeracodeBuildSettings.targets
(
echo  ^<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"^>
echo   ^<PropertyGroup^>
echo     ^<!-- The directory of the primary output file for the build --^>
echo     ^<PreprocessOutputPath^>^$^(TargetDir^)^</PreprocessOutputPath^>
echo     ^<!-- Write output to a directory for each project --^>
echo     ^<PreprocessOutputProjectPath^>^$^(PreprocessOutputPath^)\^$^(ProjectName^)^</PreprocessOutputProjectPath^>
echo   ^</PropertyGroup^>
echo   ^<ItemDefinitionGroup^>
echo     ^<ClCompile^>
echo       ^<!-- /Y-  Ignore precompiled header options --^>
echo       ^<!-- /P   Preprocess to a file              --^>
echo       ^<!-- /Fi  Preprocess output file name       --^>
echo       ^<AdditionalOptions^>/Y- /P /Fi"$(PreprocessOutputProjectPath)\\"^</AdditionalOptions^>
echo     ^</ClCompile^>
echo   ^</ItemDefinitionGroup^>
echo   ^<!-- Preprocess target runs all Build targets up to ClCompile --^>
echo   ^<Target Name="Preprocess" DependsOnTargets="PrepareForBuild;ResolveReferences;PreBuildEvent;ClCompile"/^>
echo   ^<!-- Define a target to create a directory to which ClCompile writes preprocessed output --^>
echo   ^<Target Name="CreatePreprocessDirs" BeforeTargets="ClCompile"^>
echo     ^<Exec Command="if not exist &quot;$(PreprocessOutputProjectPath)&quot; mkdir &quot;$(PreprocessOutputProjectPath)&quot;" /^>
echo   ^</Target^>
echo  ^</Project^>
) > %targets_file%

:: Build startup project in each solution
set build_dir=%repo_root%\.veracode\output\genpos\nbpos
msbuild nhpos\WS_AllSource.sln /t:Preprocess^
 /p:OutDir=%build_dir%\^
 /p:ForceImportAfterCppTargets=%targets_file%^
 /p:Configuration=Debug^
 /m

 
set build_dir=%repo_root%\.veracode\output\genpos\pep
msbuild PEP\allPepPCIF.sln /t:Preprocess^
 /p:OutDir=%build_dir%\^
 /p:ForceImportAfterCppTargets=%targets_file%^
 /p:Configuration=Debug^
 /m

:: Package files
set build_dir=%repo_root%\.veracode\output\genpos
pushd %build_dir%
tar -c -f %manual_dir%\genpos.tgz *

popd
popd
popd
