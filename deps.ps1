$BuildToolsExe = ".\vs_BuildTools.exe"
if (-not (Test-Path $BuildToolsExe)) {
	Invoke-WebRequest https://aka.ms/vs/17/release/vs_BuildTools.exe -OutFile $BuildToolsExe
}
.\vs_BuildTools.exe --config "$PWD\.vsconfig" --quiet --wait --norestart --nocache
