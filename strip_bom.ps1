# Remove UTF-8 BOM from all files in src
$files = Get-ChildItem -Path "src" -Recurse -File
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$count = 0

foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
        [System.IO.File]::WriteAllText($f.FullName, $text, $utf8NoBom)
        Write-Host "Removed BOM from: $($f.FullName)"
        $count++
    }
}

Write-Host "Completed. Removed BOM from $count files."
