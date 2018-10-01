Mock -ModuleName $ModuleName Get-AzureRmResourceGroup { return $null }

Mock -ModuleName $ModuleName New-AzureRmResourceGroup { return $null }

Mock -ModuleName $ModuleName New-AzureRmResourceGroupDeployment {
    $mockDeploymentParameters = @{}
    foreach ($key in $TemplateParameterObject.Keys) {
        $deploymentVariableMock = @{
            Type  = ($TemplateParameterObject.$key).GetType().Name
            Value = $TemplateParameterObject.$key
        }
        if (($deploymentVariableMock.Type -eq "Object[]") -or ($deploymentVariableMock.Type -eq "Hashtable")) {
            $deploymentVariableMock.Type = ($TemplateParameterObject.$key).GetType().BaseType.Name
            $deploymentVariableMock.Value = (, $TemplateParameterObject.$key | ConvertTo-Json)
        }
        $mockDeploymentParameters.Add($key, $deploymentVariableMock)
    }
    $mockDeploymentResult = [ordered]@{
        DeploymentName          = $Name
        ResourceGroupName       = $ResourceGroupName
        ProvisioningState       = "Succeeded"
        Timestamp               = "NOTSTAMPED"
        Mode                    = $Mode
        TemplateLink            = ""
        Parameters              = $mockDeploymentParameters
        Outputs                 = ""
        DeploymentDebugLogLevel = $DeploymentDebugLogLevel
    }
    return $mockDeploymentResult
}

Mock -ModuleName $ModuleName Get-AzureRmResourceGroupDeployment {
    if (![string]::IsNullOrEmpty($ResourceGroupName)) {
        $currentValues = [hashtable]@{
            Blue42Password = "PasswordPasswordPassword"
        }
        return New-B42Deployment -ResourceGroupName "stackedDeploymentTest" -Templates @("Blue42.Test", "Blue42.Alt") -TemplatePath $ResourceGroupName -TemplateParameters $currentValues
    }
}

Mock -ModuleName $ModuleName Get-AzureRmContext {
    @{
        Name             = "Mock Subscription - f1039fc7-6cc7-4191-86b6-aeb4b7df0fa9"
        Account          = @{
            Id = "user@domain.com"
        }
        SubscriptionName = "Azure Subscription"
        Tenant           = @{
            Id = "36332425-a4bc-4efc-b4ea-33b22c5e5c6f"
        }
        Environment      = "AzureCloud"
    }
}

Mock -ModuleName $ModuleName Get-AzureRmADUser {
    @{
        UserPrincipalName = "user@domain.com"
        DisplayName       = "Us Er"
        Id                = "24e6389f-e3a3-4c0e-8b66-540f3ebd13a4"
        Type              = "User"
    }
}
