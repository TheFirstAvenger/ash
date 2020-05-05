defmodule Ash.Dsl.Resource do
  use Ash.Resource,
    type: "resource",
    name: "resources",
    description: "The underlying representation of a resource in ash"

  use Ash.DataLayer.Ets

  actions do
    create :default
    read :default
  end

  attributes do
    attribute :name, :atom, allow_nil?: false, primary_key?: true
    attribute :identifier, :atom, allow_nil?: false
    attribute :description, :string, allow_nil?: false, default: {:constant, "No description"}
    # TODO: validate these
    attribute :max_page_size, :integer
    attribute :default_page_size, :integer
  end

  relationships do
    has_many :attributes, Ash.Dsl.Attribute
    has_many :has_many_relationships, Ash.Dsl.HasMany
    has_many :has_one_relationships, Ash.Dsl.HasOne
    has_many :belongs_to_relationships, Ash.Dsl.BelongsTo
    has_many :many_to_many_relationships, Ash.Dsl.ManyToMany
    has_many :create_actions, Ash.Dsl.CreateAction
    has_many :read_actions, Ash.Dsl.ReadAction
    has_many :update_actions, Ash.Dsl.UpdateAction
    has_many :destroy_actions, Ash.Dsl.DestroyAction
  end

  def groups() do
    [
      has_many_relationships: [group: :relationships, name: :has_many],
      belongs_to_relationships: [group: :relationships, name: :belongs_to],
      many_to_many_relationships: [group: :relationships, name: :many_to_many],
      has_one_relationships: [group: :relationships, name: :has_one],
      create_actions: [group: :actions, name: :create],
      read_actions: [group: :actions, name: :read],
      update_actions: [group: :actions, name: :update],
      destroy_actions: [group: :actions, name: :destroy]
    ]
  end
end
