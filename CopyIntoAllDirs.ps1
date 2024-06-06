<# Example: .\CopyIntoAllDirs.ps1 -filePath 'C:\Users\Stepper\Pictures\banner.png' -dirPath 'C:\Games\itgmania\Songs\My First Pack' #>

param(
    [string]$filePath,
    [string]$dirPath
)

# Check if the file exists
if (!(Test-Path -LiteralPath $filePath)) {
    Write-Host "The file $filePath does not exist."
    exit
}

# Check if the directory exists
if (!(Test-Path -LiteralPath $dirPath)) {
    Write-Host "The directory $dirPath does not exist."
    exit
}

# Get all subdirectories
$subDirs = Get-ChildItem -LiteralPath $dirPath -Recurse -Directory

# Copy the file into each subdirectory
foreach ($subDir in $subDirs) {
    $destinationPath = Join-Path -Path $subDir.FullName -ChildPath (Split-Path -Path $filePath -Leaf)
    Copy-Item -LiteralPath $filePath -Destination $destinationPath
}

Write-Host "File has been copied to all subdirectories of $dirPath."
