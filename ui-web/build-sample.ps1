$WEB_SAMPLES_DIR = "$PSScriptRoot/samples"

try {
    Push-Location "$PSScriptRoot/.."

    npm ci
    
    Write-Host "Building ui-web sample project..."
    Push-Location $WEB_SAMPLES_DIR

    npm run build
    $exitCode = $LASTEXITCODE

    Pop-Location

    if ($exitCode -ne 0) {
        throw "The npm build command failed with exit code $exitCode"
    }

} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    Exit 1
}
