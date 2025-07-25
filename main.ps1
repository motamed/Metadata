param(
    [Parameter(Mandatory=$true)]
    [string]$PoolName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

# Fetch metadata
$metadata = Invoke-RestMethod `
  -Headers @{Metadata="true"} `
  -Method GET `
  -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01"

# Extract computer name from metadata
$computerName = $metadata.compute.osProfile.computerName

# Create JSON payload with the extracted information
$jsonPayload = @{
    computerName = $computerName
    vmName = $metadata.compute.name
    resourceGroup = $metadata.compute.resourceGroupName
    location = $metadata.compute.location
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    poolname = $PoolName
    projectname = $ProjectName
} | ConvertTo-Json -Depth 2

Write-Host "`nJSON Payload:" -ForegroundColor Yellow
Write-Host $jsonPayload -ForegroundColor White

# Configure the endpoint URL (replace with your actual endpoint)
$endpointUrl = "https://prod-12.uaenorth.logic.azure.com:443/workflows/91da8d0bc79548d0a2e8c60ffc4293bb/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=J4IRpbVtAHBtvGd4thpdUwOjG2zHrfmXxB9ZK8m8lrA"  # Replace with your actual URL

# Prepare headers for the POST request
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    Write-Host "`nSending POST request to endpoint..." -ForegroundColor Blue
    Write-Host "URL: $endpointUrl" -ForegroundColor Cyan
    
    # Make the POST request
    $response = Invoke-RestMethod -Uri $endpointUrl -Method Post -Body $jsonPayload -Headers $headers
    
    Write-Host "`nPOST request successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 3 | Write-Host
    
} catch {
    Write-Error "Failed to send POST request: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    }
}