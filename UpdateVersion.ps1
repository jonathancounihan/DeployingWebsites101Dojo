<#
Update version number script for build
#>
param(
    [String]$BuildNumber = "usecurrent",
    [String]$RevisionNumber = "usecurrent",
	[String]$Filename = "AssemblyInfo.cs",
	[String]$VersionFilename = "Version.txt",
	[String]$WorkingDirectory = ""
)

# required to generate a proper exit code on errors.
trap 
{ 
  Write-Error $_.Exception | format-list -force
  exit 1 
}

# Get Start Time
$startDTM = (Get-Date)

Write-Host ("Running version update script for Revision Number {0} Build Number {1}" -f $RevisionNumber, $BuildNumber)
Write-Host ("Version Filename: {0}" -f $VersionFilename)
Write-Host ("Working Directory: {0}" -f $WorkingDirectory)

Set-Location -Path $workingDirectory

Write-Host ("Getting version number from file...")
[String]$versionContent = Get-Content($VersionFilename) -ErrorAction Stop

$version = New-Object System.Version($versionContent.ToString()) -ErrorAction Stop
$oldVersionNumber = $version.ToString(4)
Write-Host ("Old Version Number: {0}." -f $oldVersionNumber)

$buildNumber = $BuildNumber
if ($buildNumber -eq "usecurrent")
{
	$buildNumber = $version.Build
}
elseif ($buildNumber -eq "increment")
{
	$buildNumber = $version.Build + 1;
}

$revisionNumber = $RevisionNumber
if ($revisionNumber -eq "usecurrent")
{
	$revisionNumber = $version.Revision
}
elseif ($revisionNumber -eq "increment")
{
	$revisionNumber = $version.Revision + 1;
}
    
[String]$newVersionNumber = "{0}.{1}.{2}.{3}" -f $version.Major, $version.Minor, $buildNumber, $revisionNumber
Write-Host ("New Version Number: {0}." -f $newVersionNumber)
$newVersion = New-Object System.Version($newVersionNumber)

[String]$newVersionNumber = $newVersion.ToString(4)

if (!$newVersionNumber) 
{
	throw "Couldn't find new version number - aborting process"
}

if ($oldVersionNumber -ne $newVersionNumber) {

	$newVersionNumber | out-file $VersionFilename

	Write-Host ("Old Version Number: {0}. New Version Number: {1}" -f $oldVersionNumber, $newVersionNumber)

	if (!$newVersionNumber) 
	{
		throw "Couldn't find new version number - aborting process"
	}

	Write-Host ("Getting files to update...")

	$files = Get-ChildItem -Path $workingDirectory -Include $filename -Recurse -ErrorAction 'SilentlyContinue'

	Write-Host ("Updating version number in {0} files..." -f $files.Length)

	foreach ($file in $files) 
	{
		$filename = $file.FullName
		$fileContent = Get-Content($filename)
		$fileContent = $fileContent.replace('AssemblyVersion("' + $oldVersionNumber + '")', 'AssemblyVersion("' + $newVersionNumber + '")')
		$fileContent = $fileContent.replace('AssemblyFileVersion("' + $oldVersionNumber + '")', 'AssemblyFileVersion("' + $newVersionNumber + '")')
		$fileContent | out-file $filename
	}
}
else {
	Write-Host -ForegroundColor White -BackgroundColor DarkYellow "No version number change, nothing to do here. Is that what you wanted?"
	$global:LASTEXITCODE = 1
}

# Get End Time
$endDTM = (Get-Date)

# Echo Time elapsed
Write-host "Elapsed Time taken: $(($endDTM-$startDTM).totalseconds) seconds"

exit $global:LASTEXITCODE