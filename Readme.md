
# Blue42

Blue42 is a PowerShell Script Module that facilitates the process of writing and using ARM templates.

## Requirements

Blue42 requires the following modules to function as intended.

+ PowerShell Core 6.1 rc4
+ AzureRm.Netcore

Blue42 requires the following modules for development.

+ InvokeBuild
+ Pester
+ PSScriptAnalyzer

## File Structure

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