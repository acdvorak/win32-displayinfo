# Windows PowerShell v5.1

################################################################################
# Elevate to Admin
################################################################################

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

	Write-Host ""

	$vsDevCmdPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat"
	if (-not (Test-Path $vsDevCmdPath)) {
		throw "VsDevCmd.bat was not found at '$vsDevCmdPath'."
	}

	$validationCommand = "`"$vsDevCmdPath`" -arch=x64 && where cl && where link && where rc"
	cmd /c $validationCommand
	if ($LASTEXITCODE -ne 0) {
		throw "VC tools installed, but Windows SDK resource compiler (rc.exe) is unavailable. Ensure Windows 10 SDK is installed in VS Build Tools Installer."
	}

	Write-Host ""
	Write-Host "Visual Studio Build Tools verification succeeded (cl/link/rc found)."
	Write-Host ""

	exit $elevated.ExitCode
}

################################################################################
# Install VS 2022 Build Tools and Windows SDKs
################################################################################

$BuildToolsExe = Join-Path $PSScriptRoot "vs_BuildTools.exe"
$VsConfigPath = Join-Path $PSScriptRoot ".vsconfig"

if (-not (Test-Path $BuildToolsExe)) {
	Write-Host "Downloading VS 2022 Build Tools installer..."
	Invoke-WebRequest "https://aka.ms/vs/17/release/vs_BuildTools.exe" -OutFile $BuildToolsExe
}

$arguments = @(
	"--config", $VsConfigPath,
	"--passive",  # Show progress UI; no user input needed
	"--wait",     # Block the shell until the installation completes
	"--norestart" # Don't prompt the user to restart
)

Write-Host "Installing minimal VS 2022 Build Tools:"

try {
	$vsConfig = Get-Content -Path $VsConfigPath -Raw | ConvertFrom-Json
} catch {
	throw "Failed to parse .vsconfig at '$VsConfigPath': $($_.Exception.Message)"
}

$components = @($vsConfig.components | Where-Object { $_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_) })
foreach ($component in $components) {
	Write-Host "  - $component"
}

Write-Host ""
Write-Host "This may take several minutes..."
Write-Host ""

$process = Start-Process -FilePath $BuildToolsExe -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
	throw "vs_BuildTools.exe failed with exit code $($process.ExitCode)."
}

Write-Host ""

################################################################################
# Install winget (required)
################################################################################

$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if ($null -eq $winget) {
	Write-Host "winget not found. Installing App Installer (winget)..."

	$wingetBundlePath = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller.msixbundle"
	Invoke-WebRequest "https://aka.ms/getwinget" -OutFile $wingetBundlePath

	try {
		Add-AppxPackage -Path $wingetBundlePath -ErrorAction Stop
	} catch {
		throw "Failed to install winget automatically. Install App Installer manually from Microsoft Store and re-run this script. Details: $($_.Exception.Message)"
	}

	$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
	if ($null -eq $winget) {
		$windowsAppsPath = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\WindowsApps"
		if (Test-Path $windowsAppsPath) {
			$env:Path = "$windowsAppsPath;$env:Path"
		}
		$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
	}

	if ($null -eq $winget) {
		throw "winget was installed, but winget.exe is still unavailable in this session. Open a new elevated PowerShell and re-run deps.ps1."
	}
}

Write-Host "winget detected at '$($winget.Source)'."
& $winget.Source --version
if ($LASTEXITCODE -ne 0) {
	throw "winget was found but failed to run."
}

Write-Host ""

################################################################################
# Install CMake
################################################################################

$cmakeCommand = Get-Command cmake.exe -ErrorAction SilentlyContinue

if ($null -eq $cmakeCommand) {
	Write-Host "CMake not found. Installing via winget..."

	$wingetArgs = @(
		"install",
		"--id", "Kitware.CMake",
		"--exact",
		"--silent",
		"--accept-package-agreements",
		"--accept-source-agreements",
		"--scope", "machine"
	)

	$wingetProcess = Start-Process -FilePath $winget.Source -ArgumentList $wingetArgs -Wait -PassThru
	if ($wingetProcess.ExitCode -ne 0) {
		throw "winget failed to install CMake (exit code $($wingetProcess.ExitCode))."
	}

	# Refresh PATH in the current session so cmake can be resolved immediately.
	$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
	$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
	$env:Path = "$machinePath;$userPath"

	# Common install location fallback.
	$commonCmakeBin = "C:\Program Files\CMake\bin"
	if ((-not (Get-Command cmake.exe -ErrorAction SilentlyContinue)) -and (Test-Path $commonCmakeBin)) {
		$env:Path = "$commonCmakeBin;$env:Path"
	}
}

$cmake = Get-Command cmake.exe -ErrorAction SilentlyContinue
if ($null -eq $cmake) {
	throw "CMake installation appears to have completed, but cmake.exe is still not found in PATH."
}

Write-Host "CMake detected at '$($cmake.Source)'."
& $cmake.Source --version
if ($LASTEXITCODE -ne 0) {
	throw "CMake was found but failed to run."
}

Write-Host ""
Write-Host "CMake verification succeeded."
