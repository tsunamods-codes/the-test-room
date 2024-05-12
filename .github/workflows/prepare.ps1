if ($env:_BUILD_BRANCH -eq "refs/heads/main" -Or $env:_BUILD_BRANCH -eq "refs/tags/canary") {
  $env:_IS_BUILD_CANARY = "true"
  $env:_IS_GITHUB_RELEASE = "true"
}
elseif ($env:_BUILD_BRANCH -like "refs/tags/*") {
  $env:_BUILD_VERSION = $env:_BUILD_VERSION.Substring(0, $env:_BUILD_VERSION.LastIndexOf('.')) + ".0"
  $env:_IS_GITHUB_RELEASE = "true"
}
$env:_RELEASE_VERSION = "v${env:_BUILD_VERSION}"

Write-Output "--------------------------------------------------"
Write-Output "RELEASE VERSION: $env:_RELEASE_VERSION"
Write-Output "--------------------------------------------------"

Write-Output "_BUILD_VERSION=${env:_BUILD_VERSION}" >> ${env:GITHUB_ENV}
Write-Output "_RELEASE_VERSION=${env:_RELEASE_VERSION}" >> ${env:GITHUB_ENV}
Write-Output "_IS_BUILD_CANARY=${env:_IS_BUILD_CANARY}" >> ${env:GITHUB_ENV}
Write-Output "_IS_GITHUB_RELEASE=${env:_IS_GITHUB_RELEASE}" >> ${env:GITHUB_ENV}

$modXmlPath = ".\src\mod.xml"

# Lint XML file
Write-Output "Linting $modXmlPath..."
xmllint $modXmlPath

# Update Mod version
$modVersion = $env:_BUILD_VERSION
[regex]$pattern = "\."
$modVersion = $pattern.replace($modVersion, ",", 1)
$modVersion = $modVersion.Replace('.', '')
(Get-Content $modXmlPath).Replace('${MOD_VERSION}', $modVersion) | Set-Content $modXmlPath

# Start the packaging
mkdir .dist\ | Out-Null
Copy-Item LICENSE .\src
iroga pack .\src --output ".\.dist\${env:_RELEASE_NAME}-${env:_RELEASE_VERSION}.iro"
