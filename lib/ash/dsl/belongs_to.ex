defmodule Ash.Dsl.BelongsTo do
  use Ash.Resource,
    name: "belongs_tos",
    type: "belongs_to"

  use Ash.DataLayer.Ets

  actions do
    create :default
    read :default
    update :default
  end

  attributes do
    attribute :name, :atom, allow_nil?: false
    attribute :destination, :atom, allow_nil?: false
    # TODO: We need to support one arg defaults that take a changeset in order to derive
    # this value from configuration on the resource
    attribute :field_type, :atom, allow_nil?: false, default: {:constant, :uuid}
    # Need one arg defaults here as well, to derive destination_field id from this resource
    attribute :destination_field, :atom, allow_nil?: false, default: {:constant, :id}
    # Need one arg defaults here as well to default to the primary key field name
    attribute :source_field, :atom, allow_nil?: false
    attribute :reverse_relationship, :atom
    attribute :define_field?, :boolean, allow_nil?: false, default: {:constant, true}

    # TODO: support array types
    attribute :write_rules, :term

    attribute :type, :atom, default: {:constant, :has_one}, writable?: false, allow_nil?: false

    attribute :cardinality, :atom,
      default: {:constant, :one},
      writable?: false,
      allow_nil?: false

    # TODO: describe that this is filled in elsewhere
    attribute :source, :atom, writable?: false

    attribute :resource_id, :uuid
  end

  def upgrade_fields() do
    [:name, :destination]
  end
end
