<#
Script to Publish projects in Solution.
#>

param(
	[ValidateNotNullOrEmpty()]
    [String]$PublishProfile = "CI",
	[ValidateNotNullOrEmpty()]
	[String]$WebProject = "DeployingWebsites101Dojo\DeployingWebsites101Dojo.csproj",
	[ValidateNotNullOrEmpty()]
	[String]$MsBuildPath = "$env:windir\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
)

# Get Start Time
$startDTM = (Get-Date)

# required to generate a proper exit code on errors.
trap 
{ 
  Write-Error $_.Exception | format-list -force
  exit 1 
}

function Get-ScriptDirectory {
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

function InvokeEveWithErrorChecking ($exePath, $arguments, $errorMessage, [int[]]$errorCodes = @(1)) {
	$global:LASTEXITCODE = 0

    & $exePath $arguments;

    if ($PSVersionTable.PSVersion.Major -ge 3) {
	    if ($errorCodes.Contains($global:LASTEXITCODE)) {
            throw $errorMessage
        } 
    }
    else {
        $errorCodes | foreach { 
            if ($_ -eq $global:LASTEXITCODE) {
                throw $errorMessage
            }
        }
    }
}

$SolutionDir = Get-ScriptDirectory;

Write-Host ("Running Publish on machine {0}, in folder {1}..." -f $env:COMPUTERNAME, $SolutionDir)

.$SolutionDir\UpdateVersion.ps1 -BuildNumber "increment"

$msbuildErrorCodes = @(1)

$PublishProfileArg = '/p:PublishProfile="' + $PublishProfile + '"';

Write-Host ("Publishing Website...")

[Array]$arguments = $WebProject, "/verbosity:minimal", "/p:DeployOnBuild=true",'/p:NoWarn="1591;0108"', "/m", '/p:BuildInParallel="true"', "/p:VisualStudioVersion=14.0", "/p:Configuration=Release", $PublishProfileArg, '/p:SolutionDir="'+$SolutionDir+'\\"';

InvokeEveWithErrorChecking $MsBuildPath $arguments "Website Publish Failed!" $msbuildErrorCodes

# Get End Time
$endDTM = (Get-Date)

# Echo Time elapsed
Write-host "Elapsed Time taken: $(($endDTM-$startDTM).totalseconds) seconds"

exit $global:LASTEXITCODE