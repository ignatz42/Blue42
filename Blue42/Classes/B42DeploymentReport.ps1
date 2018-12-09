class B42DeploymentReport {
    [System.Collections.Specialized.OrderedDictionary] $Parameters = @{}
    [System.Object[]] $Deployments = @()
    [int] $SuccessfulDeploymentCount = 0
    [int] $MismatchedParameters = 0

    [bool] SimpleReport() {
        if (($this.Deployments.Count -eq 0) -or ($this.SuccessfulDeploymentCount -eq 0) -or ($this.MismatchedParameters -ne 0)) { return $false }
        return (($this.SuccessfulDeploymentCount / $this.Deployments.Count) -eq 1)
    }
}
