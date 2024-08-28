$sdkRepositoryPath = $Env:SDK_REPOSITORY_PATH 
$githubPAT = $Env:PAT_GITHUB
try {
    Set-Location "$PSScriptRoot/sdk"

    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
    
    # Commit and push to sub module
    $remoteOrigin = "https://$githubPAT@github.com/trinsic-id/sdk-swift-ui.git"
    Write-Host "Setting origin to $remoteOrigin"
    git remote set-url origin $remoteOrigin

    Write-Host "Checking out main branch"
    # If we don't do this we're in a detached head state
    git checkout main

    $version = &"$PSScriptRoot\..\get-version.ps1" -versionName "swiftUIVersion";

    # Define the path to the podspec file
    $podspecPath = "TrinsicUI.podspec"

    # Read the podspec file content
    $podspecContent = Get-Content $podspecPath

    # Update the version and tag in the podspec content
    $updatedContent = $podspecContent -replace "s.version\s*=\s*'[\d\.]+'", "s.version          = '$version'"
    $updatedContent = $updatedContent -replace "s.source\s*=\s*{ :git => '[^']+', :tag => 'v[\d\.]+' }", "s.source       = { :git => 'https://github.com/trinsic-id/sdk-swift-ui.git', :tag => 'v$version' }"

    # Write the updated content back to the podspec file
    $updatedContent | Set-Content $podspecPath

    Write-Host "Podspec file updated with version $version."

    Write-Host "Adding files to git"
    git add .

    Write-Host "Committing files"
    git commit -m "Publishing latest ui-swift package for version $packageVersion"
    
    Write-Host "Pushing to submodule repository"
    git push origin main

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push to submodule main"
    }

    $tagName = "v$version"
    git tag $tagName
    git push origin $tagName


    $netrcContent = "machine https://github.com`nlogin engineering@trinsic.id`npassword $env:COCOAPODS_TRUNK_TOKEN"
    $netrcContent | Out-File -FilePath $HOME/.netrc -Encoding utf8
    chmod 600 $HOME/.netrc

    $netrcContent = Get-Content -Path $HOME/.netrc
    Write-Host "Contents of .netrc file: $netrcContent"

    Write-Host "Pushing to CocoaPods trunk"

    pod trunk push TrinsicUI.podspec

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push to CocoaPods trunk"
    }

    # Go back to main repo and update reference
    Set-Location "$PSScriptRoot/../"
    $remoteOrigin = "https://$githubPAT@github.com/$sdkRepositoryPath.git"
    Write-Host "Setting origin to $remoteOrigin"
    git remote set-url origin $remoteOrigin

    # Update reference in main repo
    git add "ui-swift/sdk"
    git commit -m "Update ui-swift submodule reference to version $packageVersion"
    git push origin main
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push to our main"
    }
}
finally {
    Pop-Location    
}