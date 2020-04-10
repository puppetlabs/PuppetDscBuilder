If (Get-Command -Name choco -CommandType Application) {
  $ChocolateyPackages = @(
    'pester'
  )

  if ($ENV:CI -ne 'True') {
    $ChocolateyPackages += @(
      'pdk'
      'vscode'
      'vscode-powershell'
      'googlechrome'
      'git'
    )
  } ElseIf ($ENV:ACCEPTANCE -eq 'true') {
    $ChocolateyPackages += 'pdk'
  }

  choco install $ChocolateyPackages -y --no-progress
}

$PowerShellModules = @(
  @{ Name = 'PSFramework' }
  @{ Name = 'PSModuleDevelopment' }
  @{ Name = 'PowerShellGet' }
  @{ Name = 'PSScriptAnalyzer' }
  @{ Name = 'PSDepend' }
  @{ Name = 'xPSDesiredStateConfiguration' }
  @{ Name = 'PSDscResources' ; RequiredVersion = '2.12.0.0' }
  @{ Name = 'Nuget' ; RequiredVersion = '1.3.3' }
)
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
ForEach ($Module in $PowerShellModules) {
  Install-Module @Module -Force
  Get-Module -ListAvailable $Module.Name
}
