[System.Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssigments", "", Scope = "*", Target = "SuppressImportModule")]
$SuppressImportModule = $false
# The dotsourced script defines ModuleManifestPath and ModuleName
. "$PSScriptRoot\..\LoadModule.ps1"

Describe -Tag 'RequiresAzureContext' "Actual Azure tests." {
    BeforeAll {
        if ($null -eq (Get-AzureRmContext)) {
            throw "Not Connected. Run Connect-AzureRmAccount to establish a context then try again."
        }

        $globals = Get-B42Globals
        $testResourceGroupName = "deploymenttest-rg"
        if ($null -eq (Get-AzureRmResourceGroup -Name $testResourceGroupName -ErrorAction 0)) {
            New-AzureRmResourceGroup -Name $testResourceGroupName -Location $globals.Location -Confirm:$false -Force
        }
    }

    $templates = Find-B42Template
    foreach ($template in $templates) {
        $parameters = Get-B42TemplateParameters -Templates @($template)
        # The following templates have a required parent parameter that must be supplied otherwise the template cannot be validated
        $subResources = @{
            DB = "sqlName"
            VMExtension = "vmName"
            VMSSExtension = "vmssName"
            VNetPeer = "vnetName"
        }
        if ($subResources.Contains($template)) {
            $parentKey = $subResources.$template
            $parameters.$parentKey = "Mock"
        }
        $armError = Test-AzureRmResourceGroupDeployment -ResourceGroupName $testResourceGroupName -TemplateFile ("{0}\{1}.json" -f $globals.TemplatePath, $template) -TemplateParameterObject $parameters
        $passed = ([string]::IsNullOrEmpty($armError.Code) -and [string]::IsNullOrEmpty($armError.Details) -and
            [string]::IsNullOrEmpty($armError.Message) -and [string]::IsNullOrEmpty($armError.Target))

        It ("{0} passes the deployment test" -f $template) {
            ($passed) | Should Be ($true)
        }

        if (!$passed) {
            Write-Warning ("Code = {0}" -f $armError.Code)
            Write-Warning ("Details = {0}" -f $armError.Details)
            Write-Warning ("Message = {0}" -f $armError.Message)
            Write-Warning ("Target = {0}" -f $armError.Target)
        }
    }

    AfterAll {
        if (!($null -eq (Get-AzureRmResourceGroup -Name $testResourceGroupName -ErrorAction 0))) {
            Remove-AzureRmResourceGroup -Name $testResourceGroupName -Confirm:$false -Force
        }

        Remove-Module $ModuleName
    }
}
