# Puppetization
## about_Puppetization

# SHORT DESCRIPTION

Explanation of how `puppet.dsc` turns PowerShell DSC Resources into Puppet Types & Providers

# LONG DESCRIPTION
This module uses the `ConvertTo-PuppetResourceApi` function to parse a PowerShell DSC resource so it can be written as a Puppet Resource API type.
The way this works is a little involved and worth explaining in full.

The `ConvertTo-PuppetResourceApi` works differently depending on if the command is run with administrator privileges or without them.
Note that in either case, the module only currently supports running this command on a machine with Windows PowerShell 5.1.

## With Administrator Privileges

If the function is run elevated with administrator privileges it will eventually call the private function `Get-DscResourceParameterInfoByCimClass`.
This can only be run with administrator privileges because those privileges are necessary to load the DSC resources as CIM instances and introspect them.

This method is the most precise and effective way to parse the DSC resources and is the **strongly suggested** scenario when Puppetizing a PowerShell module with DSC resources at this time.
_Only_ with this function can the module parse and convert nested CIM instances effectively.

The way that `Get-DscResourceParameterInfoByCimClass` works is by invoking the specified DSC resource once with a nonsense property set - it doesn't matter that this will always error, it _also_ ensures the resource is loaded into memory and becomes parseable.
The function then looks for embedded CIM instances, parsing and walking those if necessary - it will figure out what the appropriate structure for them is in Puppet (what keys are required and what types of values each key can take), and it is capable of parsing even deeply nested CIM instances.

It then maps all of the properties for the DSC Resource, discarding any that are not needed, before doing a little work to check on the following:

- Whether or not the DSC Resource Property is marked as the `Key` - if so, it will set the metadata properties `is_namevar`, `mandatory_for_get`, and `mandatory_for_set` to `true`.
- Whether or not the DSC Resource Property is marked as `Required` - if so, it will set `mandatory_for_get` and `mandatory_for_set` to `true`.
- Whether or not the DSC Resource Property is an embedded CIM instance - if so, it will set `mof_is_embedded` to `true`.

## Without Administrator Privileges

If `ConvertTo-PuppetResourceApi` is run in an unelevated session _without_ administrator priviliges, it will eventually call the private function `Get-DscResourceParameterInfo`.
This function will, where possible, attempt to parse the AST of the PowerShell script file which defines the DSC Resource being converted.
Doing so enables us to retrieve the default value for properties that have them, retrieve the help information for each property, and tell the difference between properties necessary for getting and setting actions.
When the AST cannot be parsed, the function instead uses our best judgement for writing a Puppet Resource API type based on the available information from running `Get-DscResource` and inspecting the `Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo` object it returns.

Unfortunately, the output from this command is less accurate and full than from `Get-DscResourceParameterInfoByCimClass` - it _cannot_ walk nested CIM instances fully, for example - and is not the preferred way to convert resources, though it _will_ work if you cannot run the commands with elevated permissions.

## Output Object

Whether you run the command with or without administrator privileges, you will eventually get back a PowerShell object which has the following properties:

- `Name`: The puppetized name of the DSC resource, which is its original name prepended with `dsc_` and downcased
- `RubyFileName`: The puppetized name of the DSC resource with `.rb` appended
- `Version`: The version of the PowerShell module the DSC resource was parsed from
- `Type`: The herestring representation of the DSC resource as converted to a Puppet Resource API type
- `Provider`: The herestring representation of the Puppet Resource API provider as customized for the DSC resource
