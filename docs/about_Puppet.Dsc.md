# Puppet.Dsc
## About Puppet.Dsc

# SHORT DESCRIPTION

This module provides a means of converting PowerShell DSC Resources into Puppet types and providers.

# LONG DESCRIPTION

This module provides a means of converting a PowerShell module containing DSC Resources into a Puppet module which vendors those DSC Resources as Puppet types and providers.

In general, this module:

1. Scaffolds out a new Puppet module
1. Downloads a copy of the specified PowerShell DSC Resource module and vendors it (and all of its dependencies) into the Puppet module
1. Updates the Puppet module based on the PowerShell module's metadata
1. Converts each DSC Resource into a Puppet Resource API type
1. Generates the appropriate Puppet types and providers files in the Puppet module
1.Generates the reference documentation in the Puppet module

## Scaffolding the Puppet module

This module uses the [Puppet Development Kit (PDK)][pdk] to initialize a Puppet module, ensuring that the puppetized PowerShell module is a valid and standardized Puppet module.

This means that the Puppet module can include all of the normal metadata and documentation as any other Puppet module you might find on the [Puppet Forge][forge].

## Vendoring the PowerShell module

A puppetized PowerShell DSC module vendors that PowerShell module and any dependencies it has into the new Puppet module.
This means you are not responsible for shipping any external code to your managed nodes - as with other Puppet modules, everything you need is "in the box," either in the generated module or the [Puppet pwshlib module][pwshlib] on which it depends.

This also means that you don't have to manage any additional versions or worry about cross-version contamination: Puppet is only and always going to use the vendored resources, not whatever else may or may not be on the target node!

## Updating the Puppet module

This module takes care of updating the Puppet module with information from the PowerShell module:

- It writes a README for the Puppet module which stipulates information, dependencies, and points both to this PowerShell module and the one it has vendored.
- It updates the Puppet module fixtures, ensuring that if all you have is the PDK and this PowerShell module, you can set up and functionally test the Puppetized module.
- It updates the Puppet module's metadata, pinning the version of the Puppet module to match the PowerShell module and inserting some useful metadata for troubleshooting.
  It also sets the issues and project URLs *not* to Puppet-owned links, but to the upstream PowerShell module's settings.

## Converting the DSC Resources to Puppet types

The heavy lifting for this module happens in the `ConvertTo-PuppetResourceApi` function, which introspects on DSC Resources, parses them, and creates a Puppetized representation of those resources.

The architecture of this process is described more in depth in [about_Puppetization][about_Puppetization].

## Writing the types and providers

The module uses a few small functions which include here-strings to to write the appropriate files.
`Get-TypeContent` takes the information parsed in the `ConvertTo-PuppetResourceApi` function and uses it to write the Puppet Resource API type file, which includes all of the appropriate metadata, parameters, and documentation.
The `Get-ProviderContent` function fills out a very small provider file; this is because all of the actual provider functionality lives in the [`dsc_base_provider`](base_provider) in the [**puppetlabs/pwshlib**](pwshlib) module.
The provider written in the Puppetized module is merely an inheritor of that base provider with the appropriate name.

## Writing the reference documentation

Next, the module uses the PDK to fill out all of the appropriate reference documentation based on the type files from the prior step.
This ensures that the reference docs show up on the forge and in a single markdown document that you can review if you download the Puppetized module.

## Finally

With all of these actions completed, you have vendored and converted a PowerShell module with DSC Resources into a Puppet module, including all of the appropriate documents and metadata for troubleshooting and use.
From that point, you can use the `Publish-PuppetModule` function to push your new module to the public forge or your own repository!

[pdk]: https://puppet.com/try-puppet/puppet-development-kit/
[forge]: https://forge.puppet.com
[about_puppetization]: https://github.com/puppetlabs/PuppetDscBuilder/blob/master/docs/about_Puppetization.md
[base_provider]: https://github.com/puppetlabs/ruby-pwsh/blob/master/lib/puppet/provider/dsc_base_provider/dsc_base_provider.rb
[pwshlib]: https://forge.puppet.com/puppetlabs/pwshlib
