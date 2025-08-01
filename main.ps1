
param(

    [Parameter(Mandatory=$true)]
    [string]$URL
)

# $PoolName = $env:POOL_NAME
# $ProjectName = $env:PROJECT_NAME

# Get machine-level environment variables
$machinePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$PoolName  = Get-ItemProperty -Path $machinePath -Name "POOL_NAME" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "POOL_NAME"
$ProjectName = Get-ItemProperty -Path $machinePath -Name "PROJECT_NAME" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "PROJECT_NAME"


# Fetch metadata 
$metadata = Invoke-RestMethod `
  -Headers @{Metadata="true"} `
  -Method GET `
  -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01"

# Extract computer name from metadata
$computerName = $metadata.compute.osProfile.computerName

# Create JSON payload for the POST request
$jsonPayload = @{
    computerName = $computerName
    poolname = $PoolName
    projectname = $ProjectName
} | ConvertTo-Json -Depth 2


$endpointUrl = $URL 

$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    
    # Make the POST request
    $response = Invoke-RestMethod -Uri $endpointUrl -Method Post -Body $jsonPayload -Headers $headers

    $response | ConvertTo-Json -Depth 3 | Write-Host
    
} catch {
    Write-Error "Failed to send POST request: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    }
}