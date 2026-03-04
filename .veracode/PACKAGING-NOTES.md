# Packaging Notes for genpos

## Repository Contents
* /nhpos/WS_AllSource.sln
    * Visual Studio 2022 solution file
* /PEP/allPepPCIF.sln
    * Visual Studio 2019 solution file

## Build Environment
* Windows 10
* Developer Command Prompt for VS 2022
* Platform Toolset Visual Studio 2019 (v142)
* MSBuild version 17.10.4+10fbfbf2e for .NET Framework

## Manual Packaging Notes for Preprocessed Files

### Overview
This package contains preprocessed files generated during the build of the genpos project.

* /nhpos
    * `.i` files for C++ source files build of /nhpos/WS_AllSource.sln
* /PEP
    * `.i` files for C++ source files build of /PEP/allPepPCIF.sln