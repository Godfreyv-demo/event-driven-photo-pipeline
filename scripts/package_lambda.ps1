$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceDir = Join-Path $repoRoot "services\image_processor\package"
$distDir = Join-Path $repoRoot "dist"
$zipPath = Join-Path $distDir "image_processor.zip"

if (-not (Test-Path $sourceDir)) {
    throw "Lambda source directory not found: $sourceDir"
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

$pythonScript = @'
import os
from pathlib import Path
import zipfile

source_dir = Path(r"SOURCE_DIR_PLACEHOLDER")
zip_path = Path(r"ZIP_PATH_PLACEHOLDER")

exclude_dirs = {"__pycache__", ".pytest_cache", ".mypy_cache", ".venv", "venv"}
exclude_exts = {".pyc", ".pyo"}

fixed_timestamp = (2024, 1, 1, 0, 0, 0)

files = []
for path in source_dir.rglob("*"):
    if not path.is_file():
        continue

    rel = path.relative_to(source_dir)

    if any(part in exclude_dirs for part in rel.parts):
        continue

    if path.suffix.lower() in exclude_exts:
        continue

    files.append(path)

files = sorted(files, key=lambda p: p.relative_to(source_dir).as_posix())

print(f"Source directory: {source_dir}")
print(f"Files to package: {len(files)}")

if len(files) == 0:
    raise RuntimeError(f"No files found to package in {source_dir}")

with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for path in files:
        rel = path.relative_to(source_dir).as_posix()
        info = zipfile.ZipInfo(rel)
        info.date_time = fixed_timestamp
        info.compress_type = zipfile.ZIP_DEFLATED
        data = path.read_bytes()
        zf.writestr(info, data)

print(f"Created zip: {zip_path}")
print(f"Zip size: {zip_path.stat().st_size} bytes")
'@

$pythonScript = $pythonScript.Replace("SOURCE_DIR_PLACEHOLDER", $sourceDir)
$pythonScript = $pythonScript.Replace("ZIP_PATH_PLACEHOLDER", $zipPath)

$tempPy = Join-Path $env:TEMP "build_lambda_zip.py"
Set-Content -Path $tempPy -Value $pythonScript -Encoding UTF8

python $tempPy

if ($LASTEXITCODE -ne 0) {
    throw "Lambda packaging failed."
}

Write-Host "Lambda package ready: $zipPath"