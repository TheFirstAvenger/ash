defmodule Ash.Dsl do
  @moduledoc """
  The built in resource DSL. The three core DSL components of a resource are:

  * attributes - `attributes/1`
  * relationships - `relationships/1`
  * actions - `actions/1`
  """

  @attribute %Ash.Dsl.Entity{
    name: :attribute,
    describe: """
    Declares an attribute on the resource

    Type can be either a built in type (see `Ash.Type`) for more, or a module
    implementing the `Ash.Type` behaviour.
    """,
    examples: [
      "attribute :first_name, :string, primary_key?: true"
    ],
    target: Ash.Resource.Attribute,
    args: [:name, :type],
    schema: Ash.Resource.Attribute.attribute_schema()
  }

  @create_timestamp %Ash.Dsl.Entity{
    name: :create_timestamp,
    describe: """
    Declares a non-writable attribute with a create default of `&DateTime.utc_now/0`
    """,
    examples: [
      "create_timestamp :inserted_at"
    ],
    target: Ash.Resource.Attribute,
    args: [:name],
    schema: Ash.Resource.Attribute.create_timestamp_schema()
  }

  @update_timestamp %Ash.Dsl.Entity{
    name: :update_timestamp,
    describe: """
    Declares a non-writable attribute with a create and update default of `&DateTime.utc_now/0`
    """,
    examples: [
      "update_timestamp :inserted_at"
    ],
    target: Ash.Resource.Attribute,
    schema: Ash.Resource.Attribute.update_timestamp_schema(),
    args: [:name]
  }

  @attributes %Ash.Dsl.Section{
    name: :attributes,
    describe: """
    A section for declaring attributes on the resource.

    Attributes are fields on an instance of a resource. The two required
    pieces of knowledge are the field name, and the type.
    """,
    entities: [
      @attribute,
      @create_timestamp,
      @update_timestamp
    ]
  }

  @has_one %Ash.Dsl.Entity{
    name: :has_one,
    describe: """
    Declares a has_one relationship. In a relationsal database, the foreign key would be on the *other* table.

    Generally speaking, a `has_one` also implies that the destination table is unique on that foreign key.
    """,
    examples: [
      """
      # In a resource called `Word`
      has_one :dictionary_entry, DictionaryEntry,
        source_field: :text,
        destination_field: :word_text
      """
    ],
    target: Ash.Resource.Relationships.HasOne,
    schema: Ash.Resource.Relationships.HasOne.opt_schema(),
    args: [:name, :destination]
  }

  @has_many %Ash.Dsl.Entity{
    name: :has_many,
    describe: """
    Declares a has_many relationship. There can be any number of related entities.
    """,
    examples: [
      """
      # In a resource called `Word`
      has_many :definitions, DictionaryDefinition,
        source_field: :text,
        destination_field: :word_text
      """
    ],
    target: Ash.Resource.Relationships.HasMany,
    schema: Ash.Resource.Relationships.HasMany.opt_schema(),
    args: [:name, :destination]
  }

  @many_to_many %Ash.Dsl.Entity{
    name: :many_to_many,
    describe: """
    Declares a many_to_many relationship. Many to many relationships require a join table.

    A join table is typically a table who's primary key consists of one foreign key to each resource.
    """,
    examples: [
      """
      # In a resource called `Word`
      many_to_many :books, Book,
        through: BookWord,
        source_field: :text,
        source_field_on_join_table: :word_text,
        destination_field: :id,
        destination_field_on_join_table: :book_id
      """
    ],
    target: Ash.Resource.Relationships.ManyToMany,
    schema: Ash.Resource.Relationships.ManyToMany.opt_schema(),
    args: [:name, :destination]
  }

  @belongs_to %Ash.Dsl.Entity{
    name: :belongs_to,
    describe: """
    Declares a belongs_to relationship. In a relational database, the foreign key would be on the *source* table.

    This creates a field on the resource with the corresponding name and type, unless `define_field?: false` is provided.
    """,
    examples: [
      """
      # In a resource called `Word`
      belongs_to :dictionary_entry, DictionaryEntry,
        source_field: :text,
        destination_field: :word_text
      """
    ],
    target: Ash.Resource.Relationships.BelongsTo,
    schema: Ash.Resource.Relationships.BelongsTo.opt_schema(),
    args: [:name, :destination]
  }

  @relationships %Ash.Dsl.Section{
    name: :relationships,
    describe: """
    A section for declaring relationships on the resource.

    Relationships are a core component of resource oriented design. Many components of Ash
    will use these relationships. A simple use case is side_loading (done via the `Ash.Query.side_load/2`).
    """,
    entities: [
      @has_one,
      @has_many,
      @many_to_many,
      @belongs_to
    ]
  }

  @create %Ash.Dsl.Entity{
    name: :create,
    describe: """
    Declares a `create` action. For calling this action, see the `Ash.Api` documentation.
    """,
    examples: [
      "create :register, primary?: true"
    ],
    target: Ash.Resource.Actions.Create,
    schema: Ash.Resource.Actions.Create.opt_schema(),
    args: [:name]
  }

  @read %Ash.Dsl.Entity{
    name: :read,
    describe: """
    Declares a `read` action. For calling this action, see the `Ash.Api` documentation.
    """,
    examples: [
      "read :read_all, primary?: true"
    ],
    target: Ash.Resource.Actions.Read,
    schema: Ash.Resource.Actions.Read.opt_schema(),
    args: [:name]
  }

  @update %Ash.Dsl.Entity{
    name: :update,
    describe: """
    Declares a `update` action. For calling this action, see the `Ash.Api` documentation.
    """,
    examples: [
      "update :flag_for_review, primary?: true"
    ],
    target: Ash.Resource.Actions.Update,
    schema: Ash.Resource.Actions.Update.opt_schema(),
    args: [:name]
  }

  @destroy %Ash.Dsl.Entity{
    name: :destroy,
    describe: """
    Declares a `destroy` action. For calling this action, see the `Ash.Api` documentation.
    """,
    examples: [
      "destroy :soft_delete, primary?: true"
    ],
    target: Ash.Resource.Actions.Destroy,
    schema: Ash.Resource.Actions.Destroy.opt_schema(),
    args: [:name]
  }

  @actions %Ash.Dsl.Section{
    name: :actions,
    describe: """
    A section for declaring resource actions.

    All manipulation of data through the underlying data layer happens through actions.
    There are four types of action: `create`, `read`, `update`, and `destroy`. You may
    recognize these from the acronym `CRUD`. You can have multiple actions of the same
    type, as long as they have different names. This is the primary mechanism for customizing
    your resources to conform to your business logic. It is normal and expected to have
    multiple actions of each type in a large application.

    If you have multiple actions of the same type, one of them must be designated as the
    primary action for that type, via: `primary?: true`. This tells the ash what to do
    if an action of that type is requested, but no specific action name is given.
    """,
    entities: [
      @create,
      @read,
      @update,
      @destroy
    ]
  }

  @resource %Ash.Dsl.Section{
    name: :resource,
    describe: """
    Resource-wide configuration
    """,
    schema: [
      description: [
        type: :string
      ]
    ]
  }

  @sections [@attributes, @relationships, @actions, @resource]

  @transformers [
    Ash.Resource.Transformers.SetRelationshipSource,
    Ash.Resource.Transformers.BelongsToAttribute,
    Ash.Resource.Transformers.BelongsToSourceField,
    Ash.Resource.Transformers.CreateJoinRelationship,
    Ash.Resource.Transformers.CachePrimaryKey,
    Ash.Resource.Transformers.SetPrimaryActions
  ]

  use Ash.Dsl.Extension,
    sections: @sections,
    transformers: @transformers
end
