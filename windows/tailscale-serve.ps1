param(
    [int]$TargetPort = 11000
)

$ErrorActionPreference = "Stop"

Write-Host "Configuring Tailscale Serve: https 443 -> http://127.0.0.1:$TargetPort"

tailscale serve --bg --https=443 "http://127.0.0.1:$TargetPort"

Write-Host ""
Write-Host "Current Tailscale Serve status:"
tailscale serve status
