# Convert Manga to CBZ - Batch Processing Script
# Processes Author1/manga1, Author1/manga2 structure
# Preserves author directory structure in output

# Configuration
$baseInput = "."
$baseOutput = ".\cbz"
$threads = 8
$testMode = $false  # Set to $true for testing with limited authors

# Ensure UTF-8 encoding for CJK characters
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Create output directory if it doesn't exist
if (-not (Test-Path $baseOutput)) {
    New-Item -ItemType Directory -Path $baseOutput -Force | Out-Null
    Write-Host "Created output directory: $baseOutput" -ForegroundColor Green
}

# Get all author folders
$authorFolders = Get-ChildItem -Path $baseInput -Directory | Where-Object { $_.Name -ne "cbz" -and $_.Name -ne ".agents" }

if ($testMode) {
    # Test mode: Process only first 2 author folders
    $authorFolders = $authorFolders | Select-Object -First 2
    Write-Host "TEST MODE: Processing only first 2 author folders" -ForegroundColor Yellow
}

$totalAuthors = $authorFolders.Count
Write-Host "Found $totalAuthors author folders to process" -ForegroundColor Cyan

# Statistics
$processedAuthors = 0
$totalMangaFolders = 0
$successfulManga = 0
$failedManga = 0
$startTime = Get-Date

# Process each author folder
foreach ($authorFolder in $authorFolders) {
    $processedAuthors++
    $authorName = $authorFolder.Name
    $authorInput = $authorFolder.FullName
    $authorOutput = Join-Path $baseOutput $authorName
    
    Write-Host ("`n=== Processing Author {0}/{1}: {2} ===" -f $processedAuthors, $totalAuthors, $authorName) -ForegroundColor Magenta
    
    # Get all manga folders in this author directory
    $mangaFolders = Get-ChildItem -Path $authorInput -Directory
    
    if ($mangaFolders.Count -eq 0) {
        Write-Host ("  No manga folders found in {0}, skipping..." -f $authorName) -ForegroundColor Yellow
        continue
    }
    
    $totalMangaFolders += $mangaFolders.Count
    Write-Host "  Found $($mangaFolders.Count) manga folder(s)" -ForegroundColor Cyan
    
    # Create author output directory
    New-Item -ItemType Directory -Path $authorOutput -Force | Out-Null
    
    # Build convert-cbz command with all manga folders
    $inputArgs = @()
    foreach ($mangaFolder in $mangaFolders) {
        $inputArgs += "-input `"$($mangaFolder.FullName)`""
    }
    
    # Build the full command
    $cmd = "convert-cbz -threads $threads $($inputArgs -join ' ') -output `"$authorOutput`""
    
    Write-Host "  Executing convert-cbz with $threads threads..." -ForegroundColor Gray
    
    try {
        # Execute the command
        $output = Invoke-Expression $cmd 2>&1
        
        # Check for errors in output
        $errorLines = $output | Where-Object { $_ -match "ERROR|Failed|error" }
        
        if ($errorLines) {
            Write-Host "  Warnings/Errors detected:" -ForegroundColor Yellow
            foreach ($line in $errorLines) {
                Write-Host "    $line" -ForegroundColor Yellow
            }
            $failedManga += ($errorLines | Where-Object { $_ -match "Failed to process" }).Count
        } else {
            $successfulManga += $mangaFolders.Count
            Write-Host "  Successfully processed $($mangaFolders.Count) manga folder(s)" -ForegroundColor Green
        }
        
        # Show summary of what was created
        $createdCBZ = Get-ChildItem -Path $authorOutput -Filter "*.cbz" -File
        if ($createdCBZ) {
            Write-Host "  Created $($createdCBZ.Count) CBZ file(s) in $authorOutput" -ForegroundColor Green
        }
        
    } catch {
        Write-Host ("  ERROR processing {0}: {1}" -f $authorName, $_) -ForegroundColor Red
        $failedManga += $mangaFolders.Count
    }
    
    # Progress update
    $elapsed = (Get-Date) - $startTime
    $avgTimePerAuthor = $elapsed.TotalSeconds / $processedAuthors
    $remainingAuthors = $totalAuthors - $processedAuthors
    $estimatedRemaining = [timespan]::FromSeconds($avgTimePerAuthor * $remainingAuthors)
    
    Write-Host "  Progress: $processedAuthors/$totalAuthors authors" -ForegroundColor Gray
    Write-Host "  Estimated time remaining: $($estimatedRemaining.ToString('hh\:mm\:ss'))" -ForegroundColor Gray
}

# Final statistics
$endTime = Get-Date
$totalTime = $endTime - $startTime

Write-Host "`n=== CONVERSION COMPLETE ===" -ForegroundColor Green
Write-Host "Total processing time: $($totalTime.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
Write-Host "Authors processed: $processedAuthors/$totalAuthors" -ForegroundColor Cyan
Write-Host "Manga folders found: $totalMangaFolders" -ForegroundColor Cyan
Write-Host "Successfully converted: $successfulManga" -ForegroundColor Green
Write-Host "Failed conversions: $failedManga" -ForegroundColor $(if ($failedManga -gt 0) { "Red" } else { "Gray" })

# Show output structure
Write-Host "`nOutput structure created in: $baseOutput" -ForegroundColor Cyan
$outputAuthors = Get-ChildItem -Path $baseOutput -Directory
Write-Host "Author directories created: $($outputAuthors.Count)" -ForegroundColor Cyan

foreach ($outputAuthor in $outputAuthors) {
    $cbzFiles = Get-ChildItem -Path $outputAuthor.FullName -Filter "*.cbz" -File
    Write-Host "  $($outputAuthor.Name): $($cbzFiles.Count) CBZ file(s)" -ForegroundColor Gray
}

Write-Host "`nDone!" -ForegroundColor Green