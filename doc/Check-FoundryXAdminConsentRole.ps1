$ErrorActionPreference = 'Stop'
$commandLineArgs = @($args)
$TenantId = $null

$eligibleRoles = [ordered]@{
    'cf1c38e5-3621-4004-a7cb-879624dced7c' = 'Application Administrator'
    '158c047a-c907-4556-b7ef-446551a6b5f7' = 'Cloud Application Administrator'
    'e8611ab8-c189-46e8-94e1-60213ab1f814' = 'Privileged Role Administrator'
    '62e90394-69f5-4237-9190-012177145e10' = 'Global Administrator'
}

function Show-Usage {
    $scriptName = Split-Path -Leaf $PSCommandPath
    @"
Usage:
  .\$scriptName [-t <tenant-id>]
  .\$scriptName -h | --help

Options:
  -t, --tenant  Target Microsoft Entra tenant GUID.
                If omitted, use the current Azure CLI tenant.
  -h, --help    Show this help.

Example:
  .\$scriptName -t 11111111-1111-4111-8111-111111111111
"@
}

for ($index = 0; $index -lt $commandLineArgs.Count; $index++) {
    $argument = [string]$commandLineArgs[$index]
    switch -Regex ($argument) {
        '^(?i:-h|--help|-help|/\?)$' {
            Show-Usage
            return
        }
        '^(?i:-t|--tenant)$' {
            if ($null -ne $TenantId) {
                Write-Output 'ERROR: Tenant was specified more than once.'
                Show-Usage
                return
            }
            if ($index + 1 -ge $commandLineArgs.Count) {
                Write-Output "ERROR: $argument requires a tenant GUID."
                Show-Usage
                return
            }
            $index++
            $TenantId = [string]$commandLineArgs[$index]
            if ($TenantId.StartsWith('-')) {
                Write-Output "ERROR: $argument requires a tenant GUID."
                Show-Usage
                return
            }
        }
        default {
            Write-Output "ERROR: Unknown argument '$argument'."
            Show-Usage
            return
        }
    }
}

function Update-ProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $segments = @($machinePath, $userPath) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $env:Path = $segments -join ';'
}

function Install-AzureCliIfMissing {
    if (Get-Command az -ErrorAction SilentlyContinue) {
        return
    }
    $runningOnWindows = if (Get-Variable IsWindows -ErrorAction SilentlyContinue) {
        $IsWindows
    }
    else {
        $env:OS -eq 'Windows_NT'
    }
    if (-not $runningOnWindows) {
        throw 'Azure CLI is not installed. Automatic installation is supported only on Windows. See https://learn.microsoft.com/cli/azure/install-azure-cli'
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Azure CLI is not installed and Windows Package Manager (winget) is unavailable. Install Azure CLI from https://aka.ms/installazurecliwindows'
    }

    Write-Host 'Azure CLI is not installed. Installing the official Microsoft.AzureCLI package with winget...'
    $null = & winget install `
        --exact `
        --id Microsoft.AzureCLI `
        --source winget `
        --silent `
        --disable-interactivity `
        --accept-package-agreements `
        --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI installation failed with winget exit code $LASTEXITCODE."
    }

    Update-ProcessPath
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw 'Azure CLI was installed, but az is not available in this PowerShell process. Open a new PowerShell window and rerun the script.'
    }
    Write-Host 'Azure CLI installation completed.'
}

function ConvertFrom-Base64Url {
    param([Parameter(Mandatory)][string]$Value)

    $base64 = $Value.Replace('-', '+').Replace('_', '/')
    switch ($base64.Length % 4) {
        0 { break }
        2 { $base64 += '==' }
        3 { $base64 += '=' }
        default { throw 'The access token contains an invalid base64url payload.' }
    }
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

function ConvertFrom-JwtPayload {
    param([Parameter(Mandatory)][string]$Token)

    $parts = $Token.Split('.')
    if ($parts.Count -ne 3) {
        throw 'Azure CLI returned an access token that is not a JWT.'
    }
    try {
        return (ConvertFrom-Base64Url $parts[1]) | ConvertFrom-Json
    }
    catch {
        throw "Unable to decode the access token payload: $($_.Exception.Message)"
    }
}

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$Operation
    )

    $raw = & az @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed. Run 'az login --tenant <tenant-id> --allow-no-subscriptions' and try again."
    }
    $text = ($raw -join "`n")
    if ([string]::IsNullOrWhiteSpace($text)) {
        throw "$Operation returned no data."
    }
    try {
        return $text | ConvertFrom-Json
    }
    catch {
        throw "$Operation returned invalid JSON."
    }
}

function Get-AzureCliAccount {
    $raw = & az account show --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        return $null
    }
    $text = ($raw -join "`n")
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }
    try {
        return $text | ConvertFrom-Json
    }
    catch {
        throw 'Azure CLI account lookup returned invalid JSON.'
    }
}

function Connect-AzureCliTenant {
    param([Parameter(Mandatory)][string]$TargetTenantId)

    Write-Host "Signing in to Microsoft Entra tenant $TargetTenantId..."
    $runningOnWindows = if (Get-Variable IsWindows -ErrorAction SilentlyContinue) {
        $IsWindows
    }
    else {
        $env:OS -eq 'Windows_NT'
    }
    $previousBrokerSetting = $env:AZURE_CORE_ENABLE_BROKER_ON_WINDOWS
    try {
        if ($runningOnWindows) {
            # WAM can stall when "Use another account" is selected. Scope the
            # documented browser-auth setting to this az login process only.
            $env:AZURE_CORE_ENABLE_BROKER_ON_WINDOWS = 'false'
        }
        & az login `
            --tenant $TargetTenantId `
            --allow-no-subscriptions `
            --only-show-errors `
            --output none
        if ($LASTEXITCODE -ne 0) {
            throw "Azure CLI sign-in to tenant $TargetTenantId failed."
        }
    }
    finally {
        if ($null -eq $previousBrokerSetting) {
            Remove-Item Env:\AZURE_CORE_ENABLE_BROKER_ON_WINDOWS -ErrorAction SilentlyContinue
        }
        else {
            $env:AZURE_CORE_ENABLE_BROKER_ON_WINDOWS = $previousBrokerSetting
        }
    }
}

function Assert-NonEmptyGuid {
    param(
        [Parameter(Mandatory)][string]$Value,
        [Parameter(Mandatory)][string]$Name
    )

    $parsed = [guid]::Empty
    if (
        -not [guid]::TryParse($Value, [ref]$parsed) -or
        $parsed -eq [guid]::Empty -or
        $Value.ToLowerInvariant() -ne $parsed.ToString()
    ) {
        throw "$Name must be a canonical non-empty GUID."
    }
    return $parsed.ToString()
}

try {
    $targetTenantId = if ([string]::IsNullOrWhiteSpace($TenantId)) {
        $null
    }
    else {
        Assert-NonEmptyGuid $TenantId 'Tenant'
    }
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    Show-Usage
    return
}

Install-AzureCliIfMissing

$account = Get-AzureCliAccount
if ($null -eq $account) {
    if ($null -eq $targetTenantId) {
        throw 'Azure CLI is not signed in. Specify -t or --tenant so the script can start browser login for the target tenant.'
    }
    Connect-AzureCliTenant $targetTenantId
    $account = Invoke-AzJson @(
        'account', 'show',
        '--only-show-errors',
        '--output', 'json'
    ) 'Azure CLI account lookup after sign-in'
}

if ($account.user.type -ne 'user') {
    throw "The current Azure CLI identity is '$($account.user.type)', not a signed-in user."
}

$activeTenantId = Assert-NonEmptyGuid ([string]$account.tenantId) 'Azure CLI tenant ID'
$targetTenantId = if ($null -eq $targetTenantId) {
    $activeTenantId
}
else {
    $targetTenantId
}

if ($activeTenantId -ne $targetTenantId) {
    Connect-AzureCliTenant $targetTenantId
    $account = Invoke-AzJson @(
        'account', 'show',
        '--only-show-errors',
        '--output', 'json'
    ) 'Azure CLI account lookup after tenant switch'
    if ($account.user.type -ne 'user') {
        throw "The Azure CLI identity in tenant $targetTenantId is '$($account.user.type)', not a signed-in user."
    }
    $activeTenantId = Assert-NonEmptyGuid ([string]$account.tenantId) 'Azure CLI tenant ID after sign-in'
    if ($activeTenantId -ne $targetTenantId) {
        throw "Azure CLI sign-in returned tenant $activeTenantId instead of $targetTenantId."
    }
}

$tokenResponse = Invoke-AzJson @(
    'account', 'get-access-token',
    '--tenant', $targetTenantId,
    '--resource', 'https://management.azure.com/',
    '--only-show-errors',
    '--output', 'json'
) 'Azure access-token acquisition'

$accessToken = [string]$tokenResponse.accessToken
if ([string]::IsNullOrWhiteSpace($accessToken)) {
    throw 'Azure CLI did not return an access token.'
}

try {
    $claims = ConvertFrom-JwtPayload $accessToken
}
finally {
    $accessToken = $null
    $tokenResponse = $null
}

$tokenTenantId = Assert-NonEmptyGuid ([string]$claims.tid) 'Token tenant ID'
if ($tokenTenantId -ne $targetTenantId) {
    throw "Azure CLI returned a token for tenant $tokenTenantId instead of $targetTenantId."
}
if ($claims.idtyp -eq 'app') {
    throw 'Azure CLI returned an app-only token instead of a delegated user token.'
}

$assignedRoleIds = @($claims.wids | ForEach-Object { ([string]$_).ToLowerInvariant() })
$matchedRoles = @(
    foreach ($role in $eligibleRoles.GetEnumerator()) {
        if ($assignedRoleIds -contains $role.Key) {
            [pscustomobject]@{
                name = $role.Value
                templateId = $role.Key
            }
        }
    }
)

$result = [ordered]@{
    verdict = if ($matchedRoles.Count -gt 0) { 'ELIGIBLE ROLE DETECTED' } else { 'NO ELIGIBLE ACTIVE BUILT-IN ROLE DETECTED' }
    eligibleRoleDetected = $matchedRoles.Count -gt 0
    tenantId = $targetTenantId
    account = [string]$account.user.name
    userObjectId = [string]$claims.oid
    matchedRoles = $matchedRoles
    accessTokenPrintedOrStored = $false
    caveat = 'This is a preflight based on active built-in roles in the token wids claim. It does not detect inactive PIM eligibility or custom roles, and the Microsoft Entra admin-consent endpoint remains authoritative.'
}

[pscustomobject]$result | ConvertTo-Json -Depth 5
