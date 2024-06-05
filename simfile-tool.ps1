param(
  [Parameter(Position = 0)]
  [string]$directoryToUse
)

if ($null -ne $directoryToUse) {
  $directoryToUse = $directoryToUse.Replace("`"","'")
}

Write-Host "Simfile Tool (6/5/2024) by sukibaby :)"
Write-Host "Check for new versions at:"
Write-Host "https://github.com/sukibaby/simfile-tool"
Write-Host ""
Write-Host "Be sure to make a backup of your files first."
Write-Host ""

#region Get-Directory
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
#endregion

#region Draw-Separator
function Draw-Separator {
  Write-Host ""
  Write-Host "--------------------------------------------------"
  Write-Host ""
}
#endregion

#region Get-Files
function Get-Files {
  param($dir,$rec)
  Get-ChildItem $dir -Include *.sm,*.ssc -Recurse:$rec
}
#endregion

#region Update-Field-Capitalization, Update-Capitalization, Update-Capitalization-StepArtist
# The result of the prompt is a global variable so it can be reused if Update-Capitalization-StepArtist is called.
function Update-Field-Capitalization {
  param($dir,$rec,$field)
  Write-Host ""
  $changeField = Read-Host -Prompt "Would you like to change the $field field capitalization? (yes/no, default is no)"
  if ($changeField -eq 'yes') {
    $global:capitalizationPromptAnswer = Read-Host -Prompt "Please enter one of the following switches: u (uppercase), t (title case), l (lower case)"
    if ($global:capitalizationPromptAnswer -notin @("u","t","l")) {
      Write-Error "Invalid switch: $global:capitalizationPromptAnswer. Please provide one of the following switches: u (uppercase), t (title case), l (lower case)"
      return
    }
    if ($field -eq "STEPARTIST") {
      Update-Capitalization-StepArtist -StepArtist_dir $dir -StepArtist_rec $rec
    } else {
      Update-Capitalization -dir $dir -rec $rec -field $field -switch $global:capitalizationPromptAnswer
    }
  }
}

function Update-Capitalization {
  param($dir,$rec,$field,$switch)
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

function Update-Capitalization-StepArtist {
  param($StepArtist_dir,$StepArtist_rec)
  $StepArtist_files = Get-Files -dir $StepArtist_dir -rec $StepArtist_rec
  foreach ($StepArtist_file in $StepArtist_files) {
    $StepArtist_content = Get-Content -LiteralPath $StepArtist_file.FullName
    for ($i = 0; $i -lt $StepArtist_content.Length; $i++) {
      if ($StepArtist_content[$i] -match "//---------------(dance-.*) - (.*?)----------------") {
        $matchedGroup = $Matches[2]
        switch ($global:capitalizationPromptAnswer) {
          "u" { $StepArtist_content[$i] = $StepArtist_content[$i].Replace($matchedGroup,$matchedGroup.ToUpper()) }
          "t" { $StepArtist_content[$i] = $StepArtist_content[$i].Replace($matchedGroup,(Get-Culture).TextInfo.ToTitleCase($matchedGroup.ToLower())) }
          "l" { $StepArtist_content[$i] = $StepArtist_content[$i].Replace($matchedGroup,$matchedGroup.ToLower()) }
        }
      }
    }
    Set-Content -Path $StepArtist_file.FullName -Value $StepArtist_content
  }
}
#endregion

#region Update-Content, Update-Offset, Update-File
function Update-Content {
  param($dir,$rec,$pattern,$replacement)
  $files = Get-Files -dir $dir -rec $rec
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    for ($i = 0; $i -lt $content.Length; $i++) {
      if ($content[$i] -match $pattern) {
        $content[$i] = $content[$i] -replace $pattern,$replacement
        break
      }
    }
    Set-Content -LiteralPath $file.FullName -Value $content
  }
}

function Update-Offset {
  param($dir,$rec)
  $files = Get-Files -dir $dir -rec $rec
  $operation = Read-Host "Do you want to add or subtract the 9ms ITG offset? (add/subtract/no)"
  $adjustment = switch ($operation) {
    "add" { 0.009 }
    "subtract" { -0.009 }
    default {
      Write-Host "No adjustment will be made."
      return
    }
  }
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    $found = $false
    $content = $content | ForEach-Object {
      if (!$found -and ($_ -match "#OFFSET")) {
        $parts = $_ -split ':'
        $semicolon = $parts[1].EndsWith(';')
        $parts[1] = $parts[1].TrimEnd(';')
        $oldOffset = $parts[1]
        $parts[1] = [double]$parts[1] + $adjustment
        if ($semicolon) {
          $parts[1] = $parts[1].ToString() + ';'
        }
        $found = $true
        Write-Host "Changed offset in $($file.FullName) from $oldOffset to $($parts[1])"
        return ($parts -join ':')
      }
      return $_
    }
    Set-Content -Path $file.FullName -Value $content
  }
}

function Update-File {
  param($file,$operations)
  $content = Get-Content -LiteralPath $file.FullName
  foreach ($operation in $operations) {
    for ($i = 0; $i -lt $content.Length; $i++) {
      if ($content[$i] -match $operation.Pattern) {
        Write-Host "Replacing '$($content[$i])' with '$($operation.Replacement)'"
        $content[$i] = $content[$i] -replace $operation.Pattern, $operation.Replacement
      }
    }
  }
  Set-Content -LiteralPath $file.FullName -Value $content
}
#endregion

#region Check-FilePaths, Remove-OldFiles
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
    Write-Warning @"
   One or more file paths contain `[` or `]`.

            Unfortunately, PowerShell doesn't handle square brackets well.

            Some operations will not succeed with these
            characters present in the file path.

            Please rename those files, and then run the tool again.                    
"@
  }
}

function Remove-OldFiles {
  param($targetDir)
  if (!(Test-Path -Path $targetDir)) {
    Write-Host "The directory `"$targetDir`" does not exist."
    return
  }
  $oldFileList = Get-ChildItem -Path $targetDir -Recurse -Filter "*.old"
  if ($oldFileList) {
    Write-Host "The following .old files were found:"
    foreach ($oldFile in $oldFileList) {
      Write-Host "`"$($oldFile.FullName)`""
    }
    $firstCheckMessage = "Do you want to remove all of the above files? (yes/no, default is no)"
    $userResponse = Read-Host -Prompt $firstCheckMessage
    if ($userResponse -eq 'yes') {
      $doubleCheckMessage = "Are you sure you want to delete these files? (yes/no, default is no)"
      $doubleCheckResponse = Read-Host -Prompt $doubleCheckMessage
      if ($doubleCheckResponse -eq 'yes') {
        foreach ($oldFile in $oldFileList) {
          Remove-Item -Path $oldFile.FullName
        }
        Write-Host "All .old files have been removed."
      } else {
        Write-Host "No files were removed."
      }
    } else {
      Write-Host "No files were removed."
    }
  } else {
    Write-Host "No .old files found in `"$targetDir`"."
  }
}
#endregion

#region Prepare-For-Filesharing
function Prepare-For-Filesharing {
  param($dir,$rec)
  # If I missed any file types that we should look for, they can be added here.
  $files = Get-ChildItem $dir -Include *.sm,*.ssc,*.mp3,*.ogg,*.png,*.gif,*.jpg,*.jpeg -Recurse:$rec

  # First, rename all the files in the directory
  $renamedFiles = @{}
  foreach ($file in $files) {
    $newFileName = $file.Name -replace '[^a-zA-Z0-9._]','_'
    try {
      Rename-Item -LiteralPath $file.FullName -NewName $newFileName -ErrorAction Stop
      $renamedFiles[$file.FullName] = Join-Path $file.Directory $newFileName
      Write-Host "Renamed file '$($file.FullName)' to '$newFileName'"
    } catch {
      Write-Warning "Failed to rename file '$($file.FullName)' to '$newFileName'. Error: $_"
      Write-Warning "Values in the simfile will not be changed."
      return
    }
  }

  # Refresh the $files variable
  $files = Get-ChildItem $dir -Include *.sm,*.ssc,*.mp3,*.ogg,*.png,*.gif,*.jpg,*.jpeg -Recurse:$rec

  # Then, update the references in each file
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    $content = $content | ForEach-Object {
      if ($_ -match "#MUSIC" -or $_ -match "#BANNER" -or $_ -match "#BACKGROUND" -or $_ -match "#CDTITLE") {
        $parts = $_ -split ':',2
        $parts[1] = $parts[1].TrimStart().Replace(' ','_')
        $_ = $parts -join ':'
      }
      $_
    }
    Set-Content -LiteralPath $file.FullName -Value $content
  }
}
#endregion

#region MAIN PROGRAM, USER INPUT SECTION

# METHOD TO GET DIRECTORY
$directoryToUse = Get-Directory -dir $directoryToUse
if ($null -eq $directoryToUse) {
  return
}

#region USER INPUT SUBREGION - INITIAL QUERIES
$recursePrompt = Read-Host -Prompt "Do you want to search in subdirectories as well? (yes/no, default is yes)"
$recurseOption = $recursePrompt -ne "no"
Write-Host ""

$simFiles = Get-Files -dir $directoryToUse -Recurse $recurseOption
if ($simFiles.Count -eq 0) {
  Write-Host "No simfiles were found. Exiting..."
  exit
}

$displayFilesPrompt = Read-Host -Prompt 'Would you like to see the complete list of files that will be modified? (yes/no, default is yes)'
if ($displayFilesPrompt -ne 'no') {
  Write-Host ""
  Write-Host "The following files will be modified."
  Write-Host "Please note you'll get a chance to confirm changes before they are applied."
  $simFiles | ForEach-Object { Write-Host $_.FullName }
}

Write-Host ""
Check-FilePaths -dir $directoryToUse
Draw-Separator # End every region in this section with a Draw-Separator so everything looks nice.
#endregion

#region USER INPUT SUBREGION - ISO-8859-1 VERIFICATION
Write-Host "To ensure compatibility with all versions of StepMania/ITG, you can check for characters which may not be rendered correctly."
Write-Host ""
$encoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$unicodeCheckParams = @{
  Prompt = 'Would you like to check for Unicode characters? (yes/no, default is no)'
  AsSecureString = $false
}
$unicodeCheckInput = Read-Host @unicodeCheckParams
if ($unicodeCheckInput -eq 'yes') {
  $unicodeFiles = Get-Files -dir $directoryToUse -Recurse $recurse
  $nonUnicodeCompliantFiles = @()
  foreach ($file in $unicodeFiles) {
    $fileContent = Get-Content -Path $file.FullName | Out-String
    $convertedContent = $encoding.GetString($encoding.GetBytes($fileContent))
    if ($convertedContent -ne $fileContent) {
      $nonUnicodeCompliantFiles += $file.FullName
    }
  }

  if ($nonUnicodeCompliantFiles.Count -eq 0) {
    Write-Host "Check completed successfully. No problematic characters were found."
  } else {
    $nonUnicodeCompliantFiles
  }
} else {}

Draw-Separator
#endregion

#region USER INPUT SUBREGION - CAPITALIZATION
$wannaCapitalize = Read-Host -Prompt 'Would you like to standardize capitalization? (yes/no, default is no)'
Write-Host "Note: This function may break Unicode-only characters."
if ($wannaCapitalize -eq 'yes') {
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "TITLE"
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "SUBTITLE"
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "ARTIST"
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "STEPARTIST"
}

Draw-Separator
#endregion

#region USER INPUT SUBREGION - OFFSET ADJUSTMENT
Update-Offset -dir $directoryToUse -rec $recurse
Draw-Separator
#endregion

#region USER INPUT SUBREGION - CHANGE FILENAME/STEP ARTIST VALUES
$operations = @()

$wannaMessage = @"
  The following section changes the text values inside the   
  simfile. It won't move any files.                          
  For example, if you plan to have a banner called           
  'banner.png' in all your song directories,                 
  you would enter banner.png when prompted. You can change   
  the banner, CD title, background, step artist, and credit  
  fields here.                                               
                                                                 
"@
Write-Host $wannaMessage
$wannaModify = Read-Host -Prompt 'Would you like to modify any of these values? (yes/no, default is no)'
if ($wannaModify -eq 'yes') {
  Write-Host ""
  $addBanner = Read-Host -Prompt 'Would you like to add a banner to all files? (yes/no, default is no)'
  if ($addBanner -eq 'yes') {
    $bannerPrompt = Read-Host -Prompt 'Enter the banner file name, including extension'
    $operations += @{ Pattern = '^#BANNER:.*?;'; Replacement = "#BANNER:$bannerPrompt;" }
  }

  Write-Host ""
  $addCDTitle = Read-Host -Prompt 'Would you like to add a CD title to all files? (yes/no, default is no)'
  if ($addCDTitle -eq 'yes') {
    $CDTitlePrompt = Read-Host -Prompt 'Enter the CD title file name, including extension'
    $operations += @{ Pattern = '^#CDTITLE:.*?;'; Replacement = "#CDTITLE:$CDTitlePrompt;" }
  }

  Write-Host ""
  $addBG = Read-Host -Prompt 'Would you like to add a background to all files? (yes/no, default is no)'
  if ($addBG -eq 'yes') {
    $BGPrompt = Read-Host -Prompt 'Enter the background file name, including extension'
    $operations += @{ Pattern = '^#BACKGROUND:.*?;'; Replacement = "#BACKGROUND:$BGPrompt;" }
  }

  Write-Host ""
  $setStepArtist = Read-Host -Prompt 'Would you like to set something for the step artist field? This is the per-chart credit. (yes/no, default is no)'
  if ($setStepArtist -eq 'yes') {
    $stepArtist = Read-Host -Prompt 'Enter the credit value'
    <# To-do: add more chart types below (pump, smx, etc) #>
    $danceTypes = @("dance-single","dance-double","dance-couple","dance-solo")
    foreach ($danceType in $danceTypes) {
      $operations += @{ Pattern = "//--------------- $danceType - (.*?) ----------------"; Replacement = "//--------------- $danceType - $stepArtist ----------------" }
    }
  }

  Write-Host ""
  $setCredit = Read-Host -Prompt 'Would you like to set something for the credit field? (This is the #CREDIT field for the simfile, not the per-chart "Step artist" field.) (yes/no, default is no)'
  if ($setCredit -eq 'yes') {
    $creditValue = Read-Host -Prompt 'Enter the credit value'
    $operations += @{ Pattern = '^#CREDIT:.*?;'; Replacement = "#CREDIT:$creditValue;" }
  }

  $files = Get-Files -dir $directoryToUse -Recurse $recurse
  $confirmation = Read-Host "Are you sure you want to apply changes? (yes/no, default is no)"
  Write-Host ""
  if ($confirmation -eq "yes") {
    foreach ($file in $files) {
      Write-Host "Applying changes to file: $($file.FullName)"
      Update-File -File $file -operations $operations
    }
  } else {
    Write-Host "No changes were made."
  }
}

Draw-Separator
#endregion

#region USER INPUT SUBREGION - FILE OPERATIONS
$oldFilesConfirm = Read-Host -Prompt 'Would you like to check for .old files and remove them if found? (yes/no, default is no)'
if ($oldFilesConfirm -eq 'yes') {
  Remove-OldFiles -targetDir $directoryToUse -Recurse $recurse
} else {
  Write-Host ""
}

Draw-Separator
#endregion

#region USER INPUT SUBREGION - PREPARE FILENAMES FOR FILESHARING
$renameFilesForSharingMessage = @"
  If you upload files to a sharing     
  service, it might change the file    
  names. This can be problematic if    
  your file names contain things like  
  spaces, parentheses, etc., to        
  prevent this your files can be       
  renamed, and your simfiles can be    
  automatically accordingly, if you    
  select `yes` here.                   

"@
Write-Host $renameFilesForSharingMessage
$renameFilesForSharingConfirm = Read-Host -Prompt 'Would you like to check for spaces and special characters and rename the files? (yes/no, default is no)'
if ($renameFilesForSharingConfirm -eq 'yes') {
  Prepare-For-Filesharing -dir $directoryToUse -rec $recurse
} else {
  Write-Host ""
}
Draw-Separator
#endregion

#region END OF PROGRAM
# Tell the user everything succeeded.
Write-Host "All done :)"
#endregion
