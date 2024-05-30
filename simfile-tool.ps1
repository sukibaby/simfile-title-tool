param(
    [Parameter(Position=0)]
    [string]$directoryToUse,
    [switch]$discord
)

if ($null -ne $directoryToUse) {
    $directoryToUse = $directoryToUse.Replace("`"", "'")
}

Write-Host "Simfile Tool (5/31/2024) by sukibaby :)"
Write-Host "Check for new versions at:"
Write-Host "https://github.com/sukibaby/simfile-tool"
Write-Host ""
Write-Host "Be sure to make a backup of your files first."
Write-Host ""

function Get-Directory {
    param($dir)
    if (!$dir -or $dir -eq "" -or !(Test-Path $dir -PathType Container)) {
        Write-Host "No directory provided."
        if (!$dir -or $dir -eq "" -or !(Test-Path $dir -PathType Container)) {
            Write-Host "Press any key to exit..."
            $null = Read-Host
            exit
        }
    }
    return $dir
}

#####################################
#     Begin Function Definitions    #
#####################################
function Get-Files {
    param($dir, $rec)
    Get-ChildItem $dir -Include *.sm,*.ssc -Recurse:$rec
}

function Update-Capitalization {
    param($dir, $rec, $field, $switch)
    $files = Get-Files -dir $dir -rec $rec
    foreach ($file in $files) {
        $content = Get-Content -LiteralPath $file.FullName
        $found = $false
        $content = $content | ForEach-Object {
            if (!$found -and ($_ -match "#$field")) {
                $parts = $_ -split ':'
                switch ($switch) {
                    "u" { $parts[1] = $parts[1].ToUpper() }
                    "t" { $parts[1] = (Get-Culture).TextInfo.ToTitleCase($parts[1].ToLower()) }
                    "l" { $parts[1] = $parts[1].ToLower() }
                }
                $found = $true
                return ($parts -join ':')
            }
            return $_
        }
        Set-Content -Path $file.FullName -Value $content
    }
}


function Update-Content {
    param($dir, $rec, $pattern, $replacement)
    $files = Get-Files -dir $dir -rec $rec
    foreach ($file in $files) {
        $content = Get-Content -LiteralPath $file.FullName
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match $pattern) {
                $content[$i] = $content[$i] -replace $pattern, $replacement
                break
            }
        }
        Set-Content -LiteralPath $file.FullName -Value $content
    }
}

function Discordifier {
    param($dir, $rec)
    $files = Get-Files -dir $dir -rec $rec
    foreach ($file in $files) {
        $content = Get-Content -LiteralPath $file.FullName
        $content = $content | ForEach-Object {
            if ($_ -match "#MUSIC" -or $_ -match "#BANNER" -or $_ -match "#BACKGROUND" -or $_ -match "#CDTITLE") {
                $parts = $_ -split ':', 2
                $parts[1] = $parts[1].TrimStart().Replace(' ', '_')
                $_ = $parts -join ':'
            }
            $_
        }
        Set-Content -Path $file.FullName -Value $content

        $newFileName = $file.Name.Replace(' ', '_')
        Rename-Item -Path $file.FullName -NewName $newFileName
    }
}


function Update-Offset {
    param($dir, $rec)
    $files = Get-Files -dir $dir -rec $rec
    $operation = Read-Host "Do you want to add, subtract 0.009, or neither? (add/subtract/neither)"
    if ($operation -eq "add") {
        $adjustment = 0.009
    } elseif ($operation -eq "subtract") {
        $adjustment = -0.009
    } elseif ($operation -eq "neither") {
        Write-Host "No adjustment will be made."
        return
    } else {
        Write-Host "Assuming 'neither', no adjustment will be made."
        return
    }
if ($operation -eq "add" -or $operation -eq "subtract") {
    foreach ($file in $files) {
        $content = Get-Content -LiteralPath $file.FullName
        $found = $false
        $content = $content | ForEach-Object {
            if (!$found -and ($_ -match "#OFFSET")) {
                $parts = $_ -split ':'
                $semicolon = $parts[1].EndsWith(';')
                $parts[1] = $parts[1].TrimEnd(';')
                $parts[1] = [double]$parts[1] + $adjustment
                if ($semicolon) {
                    $parts[1] = $parts[1].ToString() + ';'
                }
                $found = $true
                return ($parts -join ':')
            }
            return $_
        }
        Set-Content -Path $file.FullName -Value $content
    }
    Write-Host "Adjustment performed."
} else {
    Write-Host "No adjustment will be made."
} 
}

Write-Host ""

function Update-File {
    param($file, $operations)
    $content = Get-Content -LiteralPath $file.FullName
    foreach ($operation in $operations) {
        for ($i = 0; $i -lt $content.Length; $i++) {
            if ($content[$i] -match $operation.Pattern) {
                Write-Host "Replacing '$($content[$i])' with '$($operation.Replacement)'"
                $content[$i] = $content[$i] -replace $operation.Pattern, $operation.Replacement
                break
            }
        }
    }
    Set-Content -LiteralPath $file.FullName -Value $content
}

$directoryToUse = Get-Directory -dir $directoryToUse
if ($null -eq $directoryToUse) {
    return
}
#####################################
#      End Function Definitions     #
#####################################

$useRecurse = Read-Host -Prompt "Do you want to search in subdirectories as well? (yes/no, default is yes)"
$recurse = $useRecurse -ne "no"
Write-Host ""

$files = Get-Files -dir $directoryToUse -recurse $recurse
if ($files.Count -eq 0) {
    Write-Host "No simfiles were found. Exiting..."
    exit
}

$showFiles = Read-Host -Prompt 'Would you like to see the complete list of files that will be modified? (yes/no, default is yes)'
if ($showFiles -ne 'no') {
    Write-Host ""
    Write-Host "The following files will be modified."
    Write-Host "Please note you'll get a chance to confirm changes before they are applied.'"
    $files | ForEach-Object { Write-Host $_.FullName }
}

Write-Host ""

function Check-FilePaths {
    param($dir)
    $files = Get-ChildItem $dir -Recurse -File
    $containsSpecialChars = $false
    foreach ($file in $files) {
        if ($file.FullName -match '\[|\]') {
            $containsSpecialChars = $true
            break
        }
    }
    if ($containsSpecialChars) {
        Write-Warning "One or more file paths contain [ or ]."
        Write-Warning "Everything should still work, but you may get error messages"
        Write-Warning "or unexpected behavior. It's recommened to rename those files."
    }
}

Check-FilePaths -dir $directoryToUse

#########################################
#             Unicode Check             #
#########################################
Write-Host "Unicode characters may not work in all versions of StepMania (or its derivatives)."
$encoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$readHostParams = @{
    Prompt         = 'Would you like to check for Unicode characters? (yes/no, default is no)'
    AsSecureString = $false
}
$userInput = Read-Host @readHostParams
if ($userInput -eq 'yes') {
    $files = Get-Files -dir $directoryToUse -recurse $recurse
    $nonCompliantFiles = @()

    foreach ($file in $files) {
        $content = Get-Content -Path $file.FullName | Out-String

        $convertedContent = $encoding.GetString($encoding.GetBytes($content))

        if ($convertedContent -ne $content) {
            $nonCompliantFiles += $file.FullName
        }
    }

    if ($nonCompliantFiles.Count -eq 0) {
        Write-Host "Check completed successfully. No problematic characters were found."
    } else {
        $nonCompliantFiles
    }
} else {}

#########################################
#         Capitalization Queries        #
#########################################
$wannaCapitalize = Read-Host -Prompt 'Would you like to standardize capitalization? (yes/no, default is no)'
if ($wannaCapitalize -eq 'yes') {

Write-Host ""
$changeTitle = Read-Host -Prompt 'Would you like to change the title field capitalization? (yes/no, default is no)'
if ($changeTitle -eq 'yes') {
    $switch = Read-Host -Prompt "Please enter one of the following switches: u (uppercase), t (title case), l (lower case)"
    if ($switch -notin @("u", "t", "l")) {
        Write-Error "Invalid switch: $switch. Please provide one of the following switches: u (uppercase), t (title case), l (lower case)"
        return
    }
    Update-Capitalization -dir $directoryToUse -rec $recurse -field "TITLE" -switch $switch
}

Write-Host ""
$changeSubtitle = Read-Host -Prompt 'Would you like to change the subtitle field capitalization? (yes/no, default is no)'
if ($changeSubtitle -eq 'yes') {
    $switch = Read-Host -Prompt "Please enter one of the following switches: u (uppercase), t (title case), l (lower case)"
    if ($switch -notin @("u", "t", "l")) {
        Write-Error "Invalid switch: $switch. Please provide one of the following switches: u (uppercase), t (title case), l (lower case)"
        return
    }
    Update-Capitalization -dir $directoryToUse -rec $recurse -field "SUBTITLE" -switch $switch
}

Write-Host ""
$changeArtist = Read-Host -Prompt 'Would you like to change the artist field capitalization? (yes/no, default is no)'
if ($changeArtist -eq 'yes') {
    $switch = Read-Host -Prompt "Please enter one of the following switches: u (uppercase), t (title case), l (lower case)"
    if ($switch -notin @("u", "t", "l")) {
        Write-Error "Invalid switch: $switch. Please provide one of the following switches: u (uppercase), t (title case), l (lower case)"
        return
    }
    Update-Capitalization -dir $directoryToUse -rec $recurse -field "ARTIST" -switch $switch
}
}
######################
#    Main Program    #
######################

Update-Offset -dir $directoryToUse -rec $recurse

$operations = @()

Write-Host ""
Write-Host "The following section changes the text values inside the simfile. It won't move any files."
Write-Host "For example, if you plan to have a banner called 'banner.png' in all your song directories,"
Write-Host "you would enter banner.png when prompted."

Write-Host ""
$addBanner = Read-Host -Prompt 'Would you like to add a banner to all files? (yes/no, default is no)'
if ($addBanner -eq 'yes') {
    $bannerPrompt = Read-Host -Prompt 'Enter the banner file name, including extension'
    $operations += @{ Pattern = '^#BANNER:.*'; Replacement = "#BANNER: $bannerPrompt" }
}

Write-Host ""
$addCDTitle = Read-Host -Prompt 'Would you like to add a CD title to all files? (yes/no, default is no)'
if ($addCDTitle -eq 'yes') {
    $CDTitlePrompt = Read-Host -Prompt 'Enter the CD title file name, including extension'
    $operations += @{ Pattern = '^#CDTITLE:.*'; Replacement = "#CDTITLE: $CDTitlePrompt" }
}

Write-Host ""
$addBG = Read-Host -Prompt 'Would you like to add a background to all files? (yes/no, default is no)'
if ($addBG -eq 'yes') {
    $BGPrompt = Read-Host -Prompt 'Enter the background file name, including extension'
    $operations += @{ Pattern = '^#BACKGROUND:.*'; Replacement = "#BACKGROUND: $BGPrompt" }
}

Write-Host ""
$setStepArtist = Read-Host -Prompt 'Would you like to set something for the step artist field? This is the per-chart credit. (yes/no, default is no)'
if ($setStepArtist -eq 'yes') {
    $stepArtist = Read-Host -Prompt 'Enter the credit value'
    $danceTypes = @("dance-single", "dance-double", "dance-couple", "dance-solo")
    foreach ($danceType in $danceTypes) {
        $operations += @{ Pattern = "//--------------- $danceType - (.*?) ----------------"; Replacement = "//--------------- $danceType - $stepArtist ----------------" }
    }
}

Write-Host ""
$setCredit = Read-Host -Prompt 'Would you like to set something for the credit field? (This is the #CREDIT field for the simfile, not the per-chart "Step artist" field.) (yes/no, default is no)'
if ($setCredit -eq 'yes') {
    $creditValue = Read-Host -Prompt 'Enter the credit value'
    $operations += @{ Pattern = '^#CREDIT:.*'; Replacement = "#CREDIT: $creditValue" }
}

$files = Get-Files -dir $directoryToUse -recurse $recurse
$confirmation = Read-Host "Are you sure you want to apply changes? (yes/no, default is no)"
Write-Host ""
if ($confirmation -eq "yes") {
    foreach ($file in $files) {
        Write-Host "Applying changes to file: $($file.FullName)"
        Update-File -file $file -operations $operations
    }
    Write-Host "All done!"
} else {
    Write-Host "No changes were made."
}

if ($discord) {
Write-Host ""
Write-Host "If you upload files to Discord, it will replace spaces in file names with underscores."
Write-Host "Would you like to rename files to replace spaces with underscores, and update the fields"
Write-Host "in the simfiles accordingly? Please note, this will rename your simfile that was named"
Write-Host "earlier, but it will not rename other files in the directory you specified."
Write-Host ""
$confirm = Read-Host -Prompt 'Would you like to replace spaces with underscores in file names and specified fields? (yes/no, default is no)'
if ($confirm -eq 'yes') {
    Discordifier -dir $directoryToUse -rec $recurse
} else {
    Write-Host "All done!"
    Write-Host ""
}
}
