defmodule Ash.Dsl.Attribute do
  use Ash.Resource,
    type: "attribute",
    name: "attributes"

  use Ash.DataLayer.Ets

  attributes do
    attribute :name, :atom, allow_nil?: false
    attribute :type, :atom, allow_nil?: false
    attribute :allow_nil?, :boolean, allow_nil?: false, default: {:constant, true}

    attribute :primary_key?, :boolean,
      allow_nil?: false,
      default: {:constant, false},
      description: "Whether or not this attribute is part of the primary key of the resource"

    attribute :writable?, :boolean, allow_nil?: false, default: {:constant, true}
    # TODO: custom validation for default format
    attribute :default, :term
    attribute :update_default, :term
    attribute :description, :string, allow_nil?: false, default: {:constant, "No description"}

    # TODO: support array types
    attribute :write_rules, :term
    attribute :resource_id, :uuid

    # TODO: ecto warns about this not existing, so I added an underscore
    # and I'm ignoring it in the parser. pretty dumb.
  end

  actions do
    create :default
    read :default
  end

  def upgrade_fields() do
    [:name, :type]
  end
end
