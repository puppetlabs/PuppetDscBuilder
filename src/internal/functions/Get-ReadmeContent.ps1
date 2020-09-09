function Get-ReadmeContent {
  <#
  .SYNOPSIS
    Return the text for a Puppet Resource API Type given a DSC Resouce.
  .DESCRIPTION
    Return the text for a Puppet Resource API Type given a DSC Resouce.
    It will return the text but _not_ directly write out the file.
  .PARAMETER PuppetModuleName
    The name of the puppet module
  .PARAMETER PowerShellModuleName
    The name of the PowerShell module being puppetized
  .PARAMETER PowerShellModuleVersion
    The version of the PowerShell module being puppetized
  .PARAMETER PowerShellModuleGalleryUri
    The full url to the PowerShell module on a nuget gallery
  .PARAMETER PowerShellModuleProjectUri
    The full url to the PowerShell module's project page/repository

  .EXAMPLE
    $Parameters = @{
      PowerShellModuleName       = 'Foo.Bar'
      PowerShellModuleGalleryUri = "https://www.powershellgallery.com/packages/Foo.Bar/1.0.0"
      PowerShellModuleProjectUri = 'https://github.com/foo/Foo.Bar'
      PowerShellModuleVersion    = '1.0.0'
      PuppetModuleName           = 'foo_bar'
    }
    Get-ReadmeContent @Parameters

    This command return a markdown readme for the puppetized foo_bar module.
  #>
  [cmdletbinding()]
  param (
    [OutputType([String])]
    [string]$PowerShellModuleName,
    [string]$PowerShellModuleDescription,
    [string]$PowerShellModuleGalleryUri,
    [string]$PowerShellModuleProjectUri,
    [string]$PowerShellModuleVersion,
    [string]$PuppetModuleName
  )

  Begin {
    $BuilderModuleGalleryUri  = 'https://www.powershellgallery.com/packages/puppet.dsc'
    $BuilderModuleRepository  = 'https://github.com/puppetlabs/PuppetDscBuilder'
    $BaseProviderSource       = 'https://github.com/puppetlabs/ruby-pwsh/blob/master/lib/puppet/provider/dsc_base_provider.rb'
    $ResourceApiOverview      = 'https://puppet.com/docs/puppet/latest/create_types_and_providers_resource_api.html'
    $ResourceApiDocumentation = 'https://puppet.com/docs/puppet/latest/about_the_resource_api.html'
    $dscForgePage             = 'https://forge.puppet.com/dsc'
    $pwshlibForgePage         = 'https://forge.puppet.com/puppetlabs/pwshlib'
    $pwshlibIssuesPage        = 'https://github.com/puppetlabs/ruby-pwsh/issues/new/choose'
    $PowerShellGetUri         = 'https://github.com/PowerShell/PowerShellGet'
    $NarrativeDocumentation   = 'https://puppetlabs.github.io/iac/news/roadmap/2020/03/30/dsc-announcement.html'
  }

  Process {
    # No additional formatting should be needed
    New-Object -TypeName System.String @"
# $PuppetModuleName

## Table of Contents

1. [Description](#description)
1. [Requirements](#requirements)
1. [Usage](#usage)
1. [Troubleshooting](#troubleshooting)

## Description

This is an auto-generated module, using the [Puppet DSC Builder]($BuilderModuleGalleryUri) to vendor and expose the [$PowerShellModuleName]($PowerShellModuleGalleryUri) PowerShell module's DSC resources as Puppet resources.
The _functionality_ of this module comes entirely from the vendored PowerShell resources, which are pinned at [**v$PowerShellModuleVersion**]($PowerShellModuleGalleryUri).
The PowerShell module describes itself like this:

> _${PowerShellModuleDescription}_

For information on troubleshooting to determine whether any encountered problems are with the Puppet wrapper or the DSC resource, see the [troubleshooting](#troubleshooting) section below.

## Requirements

This module, like all [auto-generated Puppetized DSC modules]($dscForgePage), relies on two important technologies in the Puppet stack: the [Puppet Resource API]($ResourceApiOverview) and the [`puppetlabs/pwshlib`]($pwshlibForgePage) Puppet module.

The Resource API provides a simplified option for writing types and providers and is responsible for how this module is structured.
The Resource API ships inside of Puppet starting with version 6.
While it is _technically_ possible to add the Resource API functionality to Puppet 5.5.x, the DSC functionality has **not** been tested in this setup.
For more information on the Resource API, review the [documentation]($ResourceApiDocumentation).

The module also depends on the `pwshlib` module.
This Puppet module includes two important things: the ruby-pwsh library for running PowerShell code from ruby and the base provider for DSC resources, which this module leverages.

All of the actual work being done to call the DSC resources vendored with this module is in [this file]($BaseProviderSource) from the `pwshlib` module.
This is important for troubleshooting and bug reporting, but doesn't impact your use of the module except that the end result will be that nothing works, as the dependency is not installed alongside this module!

## Usage

You can specify any of the DSC resources from this module like a normal Puppet resource in your manifests.
The examples below use DSC resources from from the [`PowerShellGet`]($PowerShellGetUri) repository, regardless of what module you're looking at here;
the syntax, not the specifics, is what's important.

For reference documentation about the DSC resources exposed in this module, see the [Reference](REFERENCE.md) file.

``````puppet
# Include a meaningful title for your resource declaration
dsc_psrepository { 'Add team module repo':
    dsc_name               => 'foo',
    # Note that we specify dsc_ensure; do NOT specify the Puppet
    # ensure property, it exists only for the underlying system.
    # You will always use dsc_ensure.
    dsc_ensure             => present,
    # This location is nonsense, can be any valid folder on your
    # machine or in a share, any location the SourceLocation param
    # for the DSC resource will accept.
    dsc_sourcelocation     => 'C:\Program Files',
    # You must always pass an enum fully lower-cased;
    # Puppet is case sensitive even when PowerShell isn't
    dsc_installationpolicy => untrusted,
}

dsc_psrepository { 'Trust public gallery':
    dsc_name               => 'PSGallery',
    dsc_ensure             => present,
    dsc_installationpolicy => trusted,
}

dsc_psmodule { 'Make Ruby manageable via uru':
  dsc_name   => 'RubyInstaller',
  dsc_ensure => present,
}
``````

For more information about using a built module, check out our [narrative documentation]($NarrativeDocumentation).

## Troubleshooting

In general, there are three broad categories of problems:

1. Problems with the way the underlying DSC resource works.
1. Problems with the type definition, where you can't specify a valid set of properties for the DSC resource
1. Problems with calling the underlying DSC resource - the parameters aren't being passed correctly or the resource can't be found

Unfortunately, problems with the way the underlying DSC resource works are something we can't help _directly_ with.
You'll need to [file an issue]($PowerShellModuleProjectUri) with the upstream maintainers for the [PowerShell module]($PowerShellModuleGalleryUri).

Problems with the type definition are when a value that should be valid according to the DSC resource's documentation and code is not accepted by the Puppet wrapper. If and when you run across one of these, please [file an issue]($BuilderModuleRepository/issues/new/choose) with the Puppet DSC Builder; this is where the conversion happens and once we know of a problem we can fix it and regenerate the Puppet modules. To help us identify the issue, please specify the DSC module, version, resource, property and values that are giving you issues. Once a fix is available we will regenerate and release updated versions of this Puppet wrapper.

Problems with calling the underlying DSC resource become apparent by comparing `<value passed in in puppet>` with `<value received by DSC>`.
In this case, please [file an issue]($pwshlibIssuesPage) with the [`puppetlabs/pwshlib`]($pwshlibForgePage) module, which is where the DSC base provider actually lives.
We'll investigate and prioritize a fix and update the `puppetlabs/pwshlib` module.
Updating to the pwshlib version with the fix will immediately take advantage of the improved functionality without waiting for this module to be reconverted and published.

For specific information on troubleshooting a generated module, check the [troubleshooting guide]($TroubleshootingDocumentation) for the `puppet.dsc` module.
"@
  }

  End {}
}
