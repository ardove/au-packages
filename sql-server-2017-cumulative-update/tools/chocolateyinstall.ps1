﻿$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url        = 'https://download.microsoft.com/download/C/4/F/C4F908C9-98ED-4E5F-88D5-7D6A5004AEBD/SQLServer2017-KB4338363-x64.exe'
$checksum   = 'e81a8ced4fc4fccbf182b72500d599e3c6c342cce2111961e88192ddcec247fd'
$softwareName = 'Hotfix 3029 for SQL Server 2017*(KB4338363)*'

$filename = [IO.Path]::GetFileName($url)

# Download like Install-ChocolateyPackage (so we can restart from cached download)
$chocTempDir = $env:TEMP
$tempDir = Join-Path $chocTempDir "$($env:chocolateyPackageName)"
if ($env:chocolateyPackageVersion -ne $null) { $tempDir = Join-Path $tempDir "$($env:chocolateyPackageVersion)"; }
$tempDir = $tempDir -replace '\\chocolatey\\chocolatey\\', '\chocolatey\'
if (![System.IO.Directory]::Exists($tempDir)) { [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null }
$downloadFilePath = Join-Path $tempDir "$($packageName)Install.$fileType"

$fullFilePath = Join-Path $toolsDir $filename

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  url           = $url
  FileFullPath  = $downloadFilePath
  checksum      = $checksum
  checksumType  = 'sha256'
}

$filePath = Get-ChocolateyWebFile @packageArgs

# Copy into tools to keep for uninstall
Copy-Item $filePath -Destination $fullFilePath

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  file  = $fullFilePath
  softwareName  = $softwareName
  silentArgs    = "/q /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances"
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyInstallPackage @packageArgs

$files = get-childitem $toolsDir -include *.exe -recurse

foreach ($file in $files) {
  # generate an ignore file
  New-Item "$file.ignore" -type file -force | Out-Null
}
