defmodule Ash.Structure.Resource do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3, attr: 2, has_many: 2]

  @name :resources
  @identifier :resource

  @attributes [
    attr(:name, :atom, allow_nil?: false, primary_key?: true),
    attr(:identifier, :atom, allow_nil?: false),
    attr(:description, :string, allow_nil?: false, default: {:constant, "No description"}),
    attr(:data_layer, :atom),
    attr(:max_page_size, :integer),
    attr(:default_page_size, :integer)
  ]

  @relationships [
    has_many(:attributes, Ash.Structure.Attribute),
    has_many(:has_many_relationships, Ash.Structure.HasMany),
    has_many(:has_one_relationships, Ash.Structure.HasOne),
    has_many(:belongs_to_relationships, Ash.Structure.BelongsTo),
    has_many(:many_to_many_relationships, Ash.Structure.ManyToMany),
    has_many(:create_actions, Ash.Structure.CreateAction),
    has_many(:read_actions, Ash.Structure.ReadAction),
    has_many(:update_actions, Ash.Structure.UpdateAction),
    has_many(:destroy_actions, Ash.Structure.DestroyAction)
  ]

  @groups [
    has_many_relationships: [group: :relationships, name: :has_many],
    belongs_to_relationships: [group: :relationships, name: :belongs_to],
    many_to_many_relationships: [group: :relationships, name: :many_to_many],
    has_one_relationships: [group: :relationships, name: :has_one],
    create_actions: [group: :actions, name: :create],
    read_actions: [group: :actions, name: :read],
    update_actions: [group: :actions, name: :update],
    destroy_actions: [group: :actions, name: :destroy]
  ]

  use Ash.Structure.Bootstrap.Resource
end
