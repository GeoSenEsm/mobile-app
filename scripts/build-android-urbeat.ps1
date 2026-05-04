param(
    [ValidateSet('apk', 'appbundle')]
    [string]$ArtifactType = 'apk'
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

Push-Location $repoRoot
try {
    $env:APP_TYPE = 'urbeat'
    dart run flutter_launcher_icons -f android_launcher_icons_urbeat.yaml
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    flutter build $ArtifactType --release --dart-define="APP_TYPE=$env:APP_TYPE"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if ($ArtifactType -eq 'apk') {
        $sourcePath = Join-Path $repoRoot 'build\app\outputs\flutter-apk\app-release.apk'
        $targetPath = Join-Path $repoRoot "build\app\outputs\flutter-apk\app-$($env:APP_TYPE)-release.apk"
    }
    else {
        $sourcePath = Join-Path $repoRoot 'build\app\outputs\bundle\release\app-release.aab'
        $targetPath = Join-Path $repoRoot "build\app\outputs\bundle\release\app-$($env:APP_TYPE)-release.aab"
    }

    Copy-Item -Path $sourcePath -Destination $targetPath -Force
    Write-Host "Saved $($env:APP_TYPE) $ArtifactType to $targetPath"
}
finally {
    Pop-Location
}