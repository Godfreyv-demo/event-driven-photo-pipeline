$ErrorActionPreference = "Stop"

Write-Host "Packaging Lambda function..."

$BuildDir = "build"
$DistDir = "dist"
$LambdaDir = "services/image_processor"
$ZipPath = Join-Path $DistDir "image_processor.zip"
$RequirementsFile = Join-Path $LambdaDir "requirements.txt"

if (-not (Test-Path $LambdaDir)) {
    throw "Lambda source directory not found: $LambdaDir"
}

if (Test-Path $BuildDir) {
    Remove-Item $BuildDir -Recurse -Force
}

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
}

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

New-Item -ItemType Directory -Path $BuildDir | Out-Null

# Copy Lambda source files
Copy-Item -Path "$LambdaDir\*" -Destination $BuildDir -Recurse -Force

# Remove files/folders that should not be deployed inside the function zip
if (Test-Path (Join-Path $BuildDir "package")) {
    Remove-Item (Join-Path $BuildDir "package") -Recurse -Force
}

if (Test-Path (Join-Path $BuildDir "Dockerfile")) {
    Remove-Item (Join-Path $BuildDir "Dockerfile") -Force
}

# Install Python dependencies into build directory if requirements.txt is not empty
if ((Test-Path $RequirementsFile) -and ((Get-Content $RequirementsFile | Where-Object { $_.Trim() -ne "" }).Count -gt 0)) {
    Write-Host "Installing Python dependencies from requirements.txt..."
    python -m pip install -r $RequirementsFile -t $BuildDir
}

Compress-Archive -Path "$BuildDir\*" -DestinationPath $ZipPath -Force

Write-Host "Lambda packaged successfully: $ZipPath"