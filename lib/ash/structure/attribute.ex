defmodule Ash.Structure.Attribute do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 2, attr: 3]

  @name :apis
  @identifier :api
  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:type, :atom, allow_nil?: false),
    attr(:allow_nil?, :boolean, allow_nil?: false, default: {:constant, true}),
    attr(:generated?, :boolean, allow_nil?: false, default: {:constant, false}),
    attr(:primary_key?, :boolean, allow_nil?: false, default: {:constant, false}),
    attr(:writable?, :boolean, allow_nil?: false, default: {:constant, true}),
    # TODO: custom/list types to make these better
    attr(:default, :term),
    attr(:update_default, :term),
    attr(:description, :string, allow_nil?: false, default: {:constant, "No description"}),
    attr(:write_rules, :term),
    attr(:resource_id, :uuid)
  ]

  @upgrade_fields [:name, :type]

  use Ash.Structure.Bootstrap.Resource
end
