function Initialize-PuppetModule {
  <#
    .SYNOPSIS
      Scafold a Puppet module
    .DESCRIPTION
      Scaffold a Puppet module and copy over static files.
    .PARAMETER OutputFolderPath
      The path, relative or literal, to the Puppet module's root folder.
    .PARAMETER PuppetModuleName
      The name of the Puppet module to create.
    .PARAMETER Confirm
      Prompts for confirmation before overwriting the file
    .PARAMETER WhatIf
      Shows what would happen if the function runs.
    .EXAMPLE
      Update-PuppetModuleFixture -PuppetModuleFolderPath ./import/powershellget
      This command will update `./import/powershellget/.fixtures.yml`, adding a
      key to the Forge Modules fixture for puppetlabs/pwshlib.
  #>
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param (
    [Parameter(Mandatory=$True)]
    [string]$OutputFolderPath,
    [Parameter(Mandatory=$True)]
    [string]$PuppetModuleName
  )

  begin {
    If (Get-Command -Name 'pct' -CommandType Application -ErrorAction SilentlyContinue) {
      $PdkTemplateFolder = Join-Path -Path $(Split-Path -Path $MyInvocation.MyCommand.Module.Path -Parent -Resolve) -ChildPath 'internal/templates/pdk'
      $Command = "pct new dsc-module --name $PuppetModuleName --output $OutputFolderPath --templatepath $PdkTemplateFolder"
      $CommandErrorFilterScript = {
        $_ -match 'ERR'
      }
    } Else {
      $Command = "pdk new module $PuppetModuleName --skip-interview --template-url https://github.com/puppetlabs/pdk-templates"
      $CommandErrorFilterScript = {
        $_ -match 'ERROR'
      }
    }
    $ModuleFolderPath = Join-Path -Path $OutputFolderPath -ChildPath $PuppetModuleName
    $StaticTemplateFolder = Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Module.Path -Parent) -ChildPath 'internal/templates/static'
  }

  process {
    Try {
      $ErrorActionPreference = 'Stop'
      # Handle folder scaffolding
      If (!(Test-Path $OutputFolderPath)) {
        $null = New-Item -Path $OutputFolderPath -ItemType Directory -Force
      }
      # Clean previously scaffolded folder
      If (Test-Path $ModuleFolderPath) {
        If ($PSCmdlet.ShouldProcess($ModuleFolderPath, 'Remove existing Puppet Module Folder')) {
          Remove-Item -Path $ModuleFolderPath -Force -Recurse
        }
      }
      Invoke-PdkCommand -Path $OutputFolderPath -Command $Command -ErrorFilterScript $CommandErrorFilterScript
      # Copy static template files
      Copy-Item -Path "$StaticTemplateFolder/*" -Destination $ModuleFolderPath -Recurse -Force
    } Catch {
      $PSCmdlet.ThrowTerminatingError($PSItem)
    }
  }

  end {}
}
