Add-Type -AssemblyName System.IO.Compression.FileSystem

$zips = Get-ChildItem -Filter *.zip

foreach ($zip in $zips) {
    Write-Host "`nExtracting ZIP: $($zip.Name)"

    $destination = Join-Path $PWD $($zip.BaseName)

    # Create extraction folder if not exists
    if (!(Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }

    try {
        $zipFile = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)

        foreach ($entry in $zipFile.Entries) {

            $targetPath = Join-Path $destination $entry.FullName
            $entryDir   = Split-Path $targetPath -Parent

            # Try to create parent folder (can fail for invalid paths)
            try {
                if (!(Test-Path $entryDir)) {
                    New-Item -ItemType Directory -Path $entryDir -Force | Out-Null
                }
            }
            catch {
                Write-Warning "⚠ Skipped folder: $entryDir — $($_.Exception.Message)"
                continue
            }

            # If entry is a folder, skip (it is already created)
            if ([string]::IsNullOrEmpty($entry.Name)) {
                Write-Host "  ✔ Created folder: $($entry.FullName)"
                continue
            }

            # Try extracting the file
            try {
                $entry.ExtractToFile($targetPath, $true)
                Write-Host "  ✔ Extracted file: $($entry.FullName)"
            }
            catch {
                Write-Warning "⚠ Skipped file: $($entry.FullName) — $($_.Exception.Message)"
                continue
            }
        }

        $zipFile.Dispose()
    }
    catch {
        Write-Warning "❌ Could not open ZIP: $($zip.Name)"
        continue
    }
}
