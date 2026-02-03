$ErrorActionPreference = "Stop"
$androidRoot = "C:\Android"
$cmdlineToolsDir = "$androidRoot\cmdline-tools"
$latestDir = "$cmdlineToolsDir\latest"
$zipPath = "$androidRoot\tools.zip"
# Using a specific known version for stability (Command-line tools 11.0)
$url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"

Write-Host "Creating directories..."
New-Item -ItemType Directory -Force -Path $androidRoot | Out-Null
New-Item -ItemType Directory -Force -Path $cmdlineToolsDir | Out-Null

Write-Host "Downloading Command Line Tools from $url..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $zipPath

Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $cmdlineToolsDir -Force

# Structure fix: content is usually in $cmdlineToolsDir\cmdline-tools. Move to $latestDir.
# The expected structure for sdkmanager is cmdline-tools/latest/bin
if (Test-Path "$cmdlineToolsDir\cmdline-tools") {
    Write-Host "Restructuring for SDK compatibility..."
    if (Test-Path $latestDir) { Remove-Item -Recurse -Force $latestDir }
    Move-Item -Path "$cmdlineToolsDir\cmdline-tools" -Destination $latestDir -Force
}

Write-Host "Installing packages (platform-tools, android-34, build-tools)..."
$sdkmanager = "$latestDir\bin\sdkmanager.bat"

# Set JAVA_HOME specifically for this session if needed, checking existing one
if (-not $env:JAVA_HOME) {
    Write-Warning "JAVA_HOME is not set. sdkmanager might fail."
} else {
    Write-Host "Using JAVA_HOME: $env:JAVA_HOME"
}

# Install and accept licenses
# We pipe 'y' to accept licenses
$installCmd = "$sdkmanager --sdk_root=$androidRoot ""platform-tools"" ""platforms;android-34"" ""build-tools;34.0.0"""
Write-Host "Running: $installCmd"
echo "y" | & $sdkmanager --sdk_root=$androidRoot "platform-tools" "platforms;android-34" "build-tools;34.0.0" --licenses
echo "y" | & $sdkmanager --sdk_root=$androidRoot "platform-tools" "platforms;android-34" "build-tools;34.0.0"

Write-Host "Installation script finished."
