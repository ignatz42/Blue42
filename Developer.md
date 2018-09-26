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

## File Structure

### base directory

Blue42.build.ps1 - Invoke-Build build script

Blue42.setting.ps1 - Custom script settings

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