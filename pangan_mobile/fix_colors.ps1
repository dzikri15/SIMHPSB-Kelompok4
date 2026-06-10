# PowerShell script untuk replace hardcoded AppColors dengan Theme.of(context).colorScheme
# Focus on text color properties: onSurface, onSurfaceVariant

$files = @(
    "lib\screens\beranda_screen.dart",
    "lib\screens\gudang_screen.dart",
    "lib\screens\panen_screen.dart",
    "lib\screens\petani\petani_beranda_screen.dart",
    "lib\screens\petani\petani_panen_screen.dart",
    "lib\screens\petani\petani_profil_screen.dart"
)

foreach ($file in $files) {
    $fullPath = Join-Path (Get-Location) $file
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        
        # Replace hardcoded text colors for onSurface
        # Pattern 1: color: AppColors.onSurface when NOT in const TextStyle
        $newContent = $content -replace 'style: TextStyle\(([^)]*?)color: AppColors\.onSurface', 'style: TextStyle($1color: Theme.of(context).colorScheme.onSurface'
        $newContent = $newContent -replace 'color: AppColors\.onSurface\)', 'color: Theme.of(context).colorScheme.onSurface)'
        
        # Pattern 2: For onSurfaceVariant
        $newContent = $newContent -replace 'style: TextStyle\(([^)]*?)color: AppColors\.onSurfaceVariant', 'style: TextStyle($1color: Theme.of(context).colorScheme.onSurfaceVariant'
        $newContent = $newContent -replace 'color: AppColors\.onSurfaceVariant\)', 'color: Theme.of(context).colorScheme.onSurfaceVariant)'
        
        if ($content -ne $newContent) {
            Set-Content $fullPath -Value $newContent -Encoding UTF8
            Write-Host "✓ Fixed: $file"
        }
    } else {
        Write-Host "✗ Not found: $file"
    }
}

Write-Host "`nDone!"
