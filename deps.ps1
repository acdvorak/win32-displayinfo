$BuildToolsExe = Join-Path $PSScriptRoot "vs_BuildTools.exe"
$VsConfigPath = Join-Path $PSScriptRoot ".vsconfig"

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
	$scriptPath = $MyInvocation.MyCommand.Path
	$elevated = Start-Process -FilePath "powershell.exe" -Verb RunAs -Wait -PassThru -ArgumentList @(
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File", "`"$scriptPath`""
	)
	exit $elevated.ExitCode
}

if (-not (Test-Path $BuildToolsExe)) {
	Write-Host "Downloading VS 2022 Build Tools installer..."
	Invoke-WebRequest "https://aka.ms/vs/17/release/vs_BuildTools.exe" -OutFile $BuildToolsExe
}

$arguments = @(
	"--config", $VsConfigPath,
	"--quiet",
	"--wait",
	"--norestart",
	"--nocache"
)

Write-Host "Installing minimal VS 2022 Build Tools..."
$process = Start-Process -FilePath $BuildToolsExe -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
	throw "vs_BuildTools.exe failed with exit code $($process.ExitCode)."
}
