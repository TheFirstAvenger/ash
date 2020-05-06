defmodule Ash.Structure.BelongsTo do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3, attr: 2]

  @name :belongs_tos
  @identifier :belongs_to

  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:destination, :atom, allow_nil?: false),
    attr(:field_type, :atom, allow_nil?: false, default: {:constant, :uuid}),
    attr(:destination_field, :atom, allow_nil?: false, default: {:constant, :id}),
    attr(:source_field, :atom, allow_nil?: false),
    attr(:reverse_relationship, :atom),
    attr(:define_field, :boolean, allow_nil?: false, default: {:constant, true}),
    attr(:write_rules, :term),
    attr(:type, :atom, default: {:constant, :has_one}, writable?: false, allow_nil?: false),
    attr(:cardinality, :atom, defualt: {:constant, :one}, writable?: false, allow_nil?: false),
    # TODO: describe that this is filled in elsewhere
    attr(:source, :atom, writable?: false),
    attr(:resource_id, :uuid)
  ]

  @upgrade_fields [:name, :destination]
  use Ash.Structure.Bootstrap.Resource
end
