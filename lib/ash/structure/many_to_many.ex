defmodule Ash.Structure.ManyToMany do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3]

  @name :many_to_manies
  @identifier :many_to_many

  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:destination, :atom, allow_nil?: false),
    attr(:field_type, :atom, allow_nil?: false, default: {:constant, :uuid}),
    attr(:destination_field, :atom, allow_nil?: false, default: {:constant, :id}),
    attr(:source_field, :atom, allow_nil?: false, default: {:constant, :id}),
    attr(:reverse_relationship, :atom),
    attr(:define_field, :boolean, allow_nil?: false, default: {:constant, true}),
    attr(:write_rules, :term),
    attr(:through, :atom, allow_nil?: false),
    attr(:source_field_on_join_table, :atom, allow_nil?: false),
    attr(:destination_field_on_join_table, :atom, allow_nil?: false),
    attr(:type, :atom, default: {:constant, :many_to_many}, writable?: false, allow_nil?: false),
    attr(:cardinality, :atom, defualt: {:constant, :many}, writable?: false, allow_nil?: false),
    # TODO: describe that this is filled in elsewhere
    attr(:source, :atom, writable?: false),
    attr(:resource_id, :uuid)
  ]

  def upgrade_fields() do
    [:name, :destination]
  end

  use Ash.Structure.Bootstrap.Resource
end
