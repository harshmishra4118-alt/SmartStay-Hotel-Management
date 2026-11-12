# =====================================================================
# SMART HOTEL MANAGEMENT SYSTEM - SAFE BACKUP SCRIPT
# Creates a dated ZIP archive excluding build binaries and credentials.
# =====================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$workspaceRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($workspaceRoot)) {
    $workspaceRoot = Get-Location
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupsDir = Join-Path $workspaceRoot "backups"
$backupZip = Join-Path $backupsDir "smart_hotel_management_backup_$timestamp.zip"
$stagingDir = Join-Path $backupsDir "staging_$timestamp"

Write-Host "==> Starting safe backup of Smart Hotel Management System..." -ForegroundColor Cyan

# 1. Ensure backups directory exists
if (-not (Test-Path $backupsDir)) {
    New-Item -ItemType Directory -Path $backupsDir -Force | Out-Null
}

# 2. Prepare clean staging directory
if (Test-Path $stagingDir) {
    Remove-Item -Recurse -Force $stagingDir
}
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

try {
    # 3. Copy project source files
    Write-Host "==> Copying project assets to staging..." -ForegroundColor Gray
    
    Copy-Item (Join-Path $workspaceRoot "pom.xml") -Destination $stagingDir
    Copy-Item (Join-Path $workspaceRoot "README.md") -Destination $stagingDir
    Copy-Item (Join-Path $workspaceRoot "PROJECT_PROGRESS.md") -Destination $stagingDir
    Copy-Item (Join-Path $workspaceRoot ".gitignore") -Destination $stagingDir
    
    Copy-Item -Recurse (Join-Path $workspaceRoot "database") -Destination (Join-Path $stagingDir "database")
    Copy-Item -Recurse (Join-Path $workspaceRoot "src") -Destination (Join-Path $stagingDir "src")

    # 4. Strict Security Sanitization: Remove live credentials if present
    $liveDbProps = Join-Path $stagingDir "src\main\resources\db.properties"
    if (Test-Path $liveDbProps) {
        Write-Host "==> Sanitizing sensitive local credentials (removing db.properties, preserving db.properties.example)..." -ForegroundColor Yellow
        Remove-Item -Force $liveDbProps
    }

    # 5. Compress staging folder into ZIP
    Write-Host "==> Creating ZIP archive: $backupZip" -ForegroundColor Gray
    Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $backupZip -CompressionLevel Optimal

    # 6. Verification
    if (Test-Path $backupZip) {
        $zipInfo = Get-Item $backupZip
        $sizeKb = [math]::Round($zipInfo.Length / 1KB, 2)
        Write-Host "==> Backup created successfully!" -ForegroundColor Green
        Write-Host "    File: $($zipInfo.FullName)" -ForegroundColor Green
        Write-Host "    Size: $sizeKb KB" -ForegroundColor Green
        Write-Host "    Time: $($zipInfo.LastWriteTime)" -ForegroundColor Green
    } else {
        throw "Backup ZIP was not created."
    }
}
finally {
    # 7. Safe cleanup of temporary staging folder
    if (Test-Path $stagingDir) {
        Remove-Item -Recurse -Force $stagingDir
    }
}
