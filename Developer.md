# Blue42 Development

## Getting started

Development for Blue42 is done with VSCode. After cloning the repository, open the folder with VSCode. The test task named 'Coverage' will run all the unit tests and generate a html page in the build_artifacts directory with statistics. The test named 'Unit' skips the code coverage and physical module test. The test named 'Integration' may only be run once an AzureRM Context is established in VSCode's integrated PowerShell terminal.

## Requirements

+ PowerShell Core 6.1
+ AzureRm.Netcore
+ InvokeBuild
+ Pester
+ PSScriptAnalyzer
+ PSCodeHealth
+ platyPS

## File Structure

### base directory

Blue42.build.ps1 - Invoke-Build build script

Blue42.setting.ps1 - Custom script settings

Setup.ps1 - Installs the required modules.

### /Blue42/ directory

#### Classes

Dynamic classes returned by some functions.

#### Private

At the base level, Blue42 has some functions that help with parsing and wring the ARM template JSON format. These functions should not be exported.

#### Public

This directory contains the exported function that make up Blue42. This directory also contains helper funcitons are used to generate the mostly security releated pre-requisites needed to facilitate ARM template deployment.

#### templates

Optional ARM templates. This collection will expand with time. The initial set of templates are primarily used for integration testing.

### /tests/ directory

Module structure test.

#### unit

Pester tests that do not require an Azure context.

#### integration

Pester tests that require an Azure context to run.

### /.vscode/ directory

tasks.json - Defines the primary build actions.
settings.json - Contains custom project settings.

## Overview

1. Install the pre-requisite modules by runnng Setup.ps1
2. Run `Invoke-Build Test Blue42.build.ps1` to run the unit tests and PSScriptAnalyzer
3. Run `Invoke-Build Publish Blue42.build.ps1` to publish the module
4. Run `Invoke-Build Docs Blue42.build.ps1` to create Markdown help files from the function comments.
5. Open the folder with VSCode and find the following tasks defined: Coverage, Unit, Integration. Coverage is the same as number two above. Unit only runs the unit tests for quick development. Integration requires an existing Azure Context to perform actual ARM template deployments.
