$package = 'mingw-get'

try {
  $files = @("mingw-get-0.6.2-mingw32-beta-20131004-1-bin.tar.xz",
  "mingw-get-0.6.2-mingw32-beta-20131004-1-lic.tar.xz",
  "mingw-get-setup-0.6.2-mingw32-beta-20131004-1-dll.tar.xz",
  "mingw-get-setup-0.6.2-mingw32-beta-20131004-1-xml.tar.xz")

  $downloadLocation = "http://prdownloads.sourceforge.net/mingw/"
  $downloadSuffix = "?download"

  $binRoot = Get-BinRoot
  Write-Debug "Bin Root is $binRoot"
  $installDir = Join-Path "$binRoot" 'MinGW'

  if (![System.IO.Directory]::Exists($installDir)) {[System.IO.Directory]::CreateDirectory($installDir)}

  $tempDir = "$env:TEMP\chocolatey\$($package)"
  if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}

  if (![System.IO.Directory]::Exists("$installDir\temp")) {[System.IO.Directory]::CreateDirectory("$installDir\temp")}

  foreach ($file in $files) {
    $url = -join ($downloadLocation, $file, $downloadSuffix)
    $filePath = Join-Path $tempDir $file
    Get-ChocolateyWebFile "$package" "$filePath" "$url"
  Write-Host "Extracting `'$filePath`' to `'$installDir`'"
  Start-Process "7za" -ArgumentList "x -y `"$filePath`" -o`"$installDir\temp`"" -Wait  -NoNewWindow -PassThru
  }

  Start-Process "7za" -ArgumentList "x -ttar -y `"$installDir\temp`" -o`"$installDir`"" -Wait  -NoNewWindow -PassThru
  Remove-Item "$installDir\temp\"
  Copy-Item "$installDir\var\lib\mingw-get\data\defaults.xml" "$installDir\var\lib\mingw-get\data\profile.xml"
  Write-Host "Adding `'$installDir\bin`' to the path and the current shell path"
  Install-ChocolateyPath "$installDir\bin" 'machine'
  $env:Path += ";$installDir\bin"
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
