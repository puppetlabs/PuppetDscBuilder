require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'dsc_psrepository',
  dscmeta_resource_friendly_name: 'PSRepository',
  dscmeta_resource_name: 'MSFT_PSRepository',
  dscmeta_module_name: 'PowerShellGet',
  dscmeta_module_version: '2.2.5',
  docs: 'The DSC PSRepository resource type.
         Automatically generated from version 2.2.5',
  features: ['simple_get_filter', 'canonicalize', 'custom_insync'],
  attributes: {
    name: {
      type:      'String',
      desc:      'Description of the purpose for this resource declaration.',
      behaviour: :namevar,
    },
    validation_mode: {
      type:      'Enum[property, resource]',
      desc:      'Whether to check if the resource is in the desired state by property (default) or using Invoke-DscResource in Test mode (resource).',
      behaviour: :parameter,
      default:   'property',
    },
    dsc_installationpolicy: {
      type: "Optional[Enum['Trusted', 'Untrusted']]",
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_psdscrunascredential: {
      type: 'Optional[Struct[{ user => String[1], password => Sensitive[String[1]] }]]',
      desc: ' ',
      behaviour: :parameter,
      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'PSCredential',
      mof_is_embedded: true,
    },
    dsc_ensure: {
      type: "Optional[Enum['Present', 'Absent']]",
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_packagemanagementprovider: {
      type: 'Optional[String]',
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_registered: {
      type: 'Optional[Boolean]',
      desc: ' ',
      behaviour: :read_only,
      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'Boolean',
      mof_is_embedded: false,
    },
    dsc_scriptsourcelocation: {
      type: 'Optional[String]',
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_name: {
      type: 'String',
      desc: ' ',
      behaviour: :namevar,
      mandatory_for_get: true,
      mandatory_for_set: true,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_publishlocation: {
      type: 'Optional[String]',
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_scriptpublishlocation: {
      type: 'Optional[String]',
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_sourcelocation: {
      type: 'Optional[String]',
      desc: ' ',

      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'String',
      mof_is_embedded: false,
    },
    dsc_trusted: {
      type: 'Optional[Boolean]',
      desc: ' ',
      behaviour: :read_only,
      mandatory_for_get: false,
      mandatory_for_set: false,
      mof_type: 'Boolean',
      mof_is_embedded: false,
    },
  },
)
