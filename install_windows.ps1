$ErrorActionPreference = "Stop"

Write-Host "Installing sucata..."

$hasExpandArchive = Get-Command Expand-Archive -ErrorAction SilentlyContinue
$has7zip = Get-Command 7z -ErrorAction SilentlyContinue

if (-not $hasExpandArchive -and -not $has7zip) {
    Write-Error "Needs Expand-Archive (PowerShell) or 7z to install Sucata"
    exit 1
}


$ARCH = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture

if ($ARCH -eq "X64") {
    $TARGET = "sucata-win-amd64"
} elseif ($ARCH -eq "Arm64") {
    #$TARGET = "sucata-win-arm64"
    Write-Error "Unsupported Windows architecture: $ARCH"
    exit 1
} else {
    Write-Error "Unsupported Windows architecture: $ARCH"
    exit 1
}

$SUCATA_VERSION = "0.1.2"
$SUCATA_NAME = "sucata.exe"
$SUCATA_URL = "https://github.com/gumpdev/sucata/releases/download/$SUCATA_VERSION/$TARGET.zip"
$SUCATA_DIR = Join-Path $HOME "sucata"
$TEMP_ZIP = Join-Path $SUCATA_DIR "temp.zip"
$BIN_PATH = Join-Path $SUCATA_DIR $SUCATA_NAME

New-Item -ItemType Directory -Force -Path $SUCATA_DIR | Out-Null

Write-Host "Downloading $SUCATA_URL"
Invoke-WebRequest -Uri $SUCATA_URL -OutFile $TEMP_ZIP -UseBasicParsing

if ($hasExpandArchive) {
    Expand-Archive -Path $TEMP_ZIP -DestinationPath $SUCATA_DIR -Force
} else {
    7z x $TEMP_ZIP "-o$SUCATA_DIR" -y | Out-Null
}

Write-Host "Sucata installed at $BIN_PATH"

$CURRENT_PATH = [Environment]::GetEnvironmentVariable("PATH", "User")

if ($CURRENT_PATH -notlike "*$SUCATA_DIR*") {
    [Environment]::SetEnvironmentVariable(
        "PATH",
        "$SUCATA_DIR;$CURRENT_PATH",
        "User"
    )
    Write-Host "Added $SUCATA_DIR to PATH"
} else {
    Write-Host "PATH already contains $SUCATA_DIR"
}

Write-Host "Done! Restart your terminal to use sucata."
