param(
    [Parameter(Mandatory=$true)]
    [string]$PoolName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [Parameter(Mandatory=$true)]
    [string]$URL
)


# Create JSON payload for the POST request
$jsonPayload = @{
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
    
} catch {
    Write-Error "Failed to send POST request: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    }
}