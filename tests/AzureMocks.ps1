#Az.Resources
Mock -ModuleName $ModuleName Get-AzResourceGroup { return $null }

Mock -ModuleName $ModuleName New-AzResourceGroup { return $null }

Mock -ModuleName $ModuleName New-AzResourceGroupDeployment {
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

Mock -ModuleName $ModuleName Get-AzResourceGroupDeployment {
    if (![string]::IsNullOrEmpty($ResourceGroupName)) {
        $currentValues = [hashtable]@{
            Blue42Password = "PasswordPasswordPassword"
        }
        return New-B42Deployment -ResourceGroupName "stackedDeploymentTest" -Templates @("Blue42.Test", "Blue42.Alt") -TemplatePath $ResourceGroupName -TemplateParameters $currentValues
    }
}

Mock -ModuleName $ModuleName Get-AzADUser {
    @{
        UserPrincipalName = "user@domain.com"
        DisplayName       = "Us Er"
        Id                = "24e6389f-e3a3-4c0e-8b66-540f3ebd13a4"
        Type              = "User"
    }
}

# Az.Profile
Mock -ModuleName $ModuleName Get-AzContext {
    @{
        Name             = "Mock Subscription - f1039fc7-6cc7-4191-86b6-aeb4b7df0fa9"
        Account          = @{
            Id = "user@domain.com"
        }
        Environment      = "AzureCloud"
        SubscriptionName = "Azure Subscription"
        Tenant           = @{
            Id = "36332425-a4bc-4efc-b4ea-33b22c5e5c6f"
        }
    }
}

# Az.Network
Mock -ModuleName $ModuleName Get-AzVirtualNetwork {
    @{Id = "3ff12cf5-4a81-4f3c-a5f0-bb5ee8a58ede"}
}

# Az.Dns
Mock -ModuleName $ModuleName New-AzDnsZone { return $null }

Mock -ModuleName $ModuleName Set-AzDnsZone { return $null }

# Az.Keyvault
Mock -ModuleName $ModuleName Set-AzKeyVaultSecret {
    $credentials = New-Object System.Net.NetworkCredential("TestUsername", $SecretValue, "TestDomain")
    @{
        VaultName       = $VaultName
        Name            = $Name
        Version         = "UID"
        Id              = "https://contoso.vault.azure.net:443/secrets/$Name/UID"
        SecretValue     = $SecretValue
        SecretValueText = $credentials.Password
    }
}

# Az.Sql
Mock -ModuleName $ModuleName Set-AzSqlServerActiveDirectoryAdministrator {
    @{
        ResourceGroupName = "$ResourceGroupName"
        ServerName        = "$ServerName"
        DisplayName       = "$DisplayName"
        ObjectId          = "AN ACTUAL GUID WOULD BE RETURNED"
    }
}

Mock -ModuleName $ModuleName New-AzSqlServerFirewallRule {return $null}

Mock -ModuleName $ModuleName Remove-AzSqlServerFirewallRule {return $null}
