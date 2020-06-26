function Assert-ModuleExists([string]$ModuleName) {
    $module = Get-Module $ModuleName -ListAvailable -ErrorAction SilentlyContinue
    if (!$module) {
        Write-Host "Installing module $ModuleName ..."
        Install-Module -Name $ModuleName -Force -Scope CurrentUser
        Write-Host "Module installed"
    }
    elseif ($module.Version -ne '1.0.0' -and $module.Version -le '1.0.410') {
        Write-Host "Updating module $ModuleName ..."
        Update-Module -Name $ModuleName -Force -ErrorAction Stop
        Write-Host "Module updated"
    }
}

# ==================================================================
# PART 1: Verify that the Power BI Management module is installed
#         and authenticate the current user.
# ==================================================================
Assert-ModuleExists -ModuleName "MicrosoftPowerBIMgmt"
$login_info = Login-PowerBI
$current_user = $login_info.UserName

# variables
$workspace_name = "PBI-Dataset-Refresh"
$dataset_name = "AdventureWorksDW-CustomerSales"

# get workspace object
$workspace = (Get-PowerBIWorkspace -Scope Organization -All | Where-Object {$_.Name -eq $workspace_name} -ErrorAction SilentlyContinue)
$workspace

# get dataset object
$dataset = (Get-PowerBIDataset -WorkspaceId $workspace.Id | Where-Object {$_.Name -eq $dataset_name})
$dataset

# build url
$refresh_url = "groups/" + $workspace.Id + "/datasets/" + $dataset.Id + "/refreshes"

# refresh dataset
$testerror = (Invoke-PowerBIRestMethod -Url $refresh_url -Method Post)