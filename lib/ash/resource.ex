defmodule Ash.Resource do
  @primary_key_schema Ashton.schema(
                        opts: [field: :atom, type: :atom, generated?: :boolean],
                        defaults: [field: :id, type: :uuid, generated?: true],
                        describe: [
                          field: "The field name of the primary key of the resource.",
                          type: "The data type of the primary key of the resource.",
                          generated?: "Whether or not the primary key is auto generated."
                        ]
                      )

  @resource_opts_schema Ashton.schema(
                          opts: [
                            name: :string,
                            type: :string,
                            primary_key: [
                              :boolean,
                              @primary_key_schema
                            ]
                          ],
                          describe: [
                            name:
                              "The name of the resource. This will typically be the pluralized form of the type",
                            type:
                              "The type of the resource, e.g `post` or `author`. This is used throughout the system.",
                            primary_key:
                              "If true, a default `id` uuid primary key that autogenerates is used. If false, none is created. See the primary_key opts for info on specifying primary key options."
                          ],
                          required: [:name, :type],
                          defaults: [
                            primary_key: true
                          ]
                        )

  # TODO: Flesh out the resource callbacks, to allow for functionally derived resources. Maybe
  # This one is just here so I can make this a behaviour, so that we can check if a module
  # is a resource or not.
  @callback primary_key() :: [atom]

  @moduledoc """
  A resource is a static definition of an entity in your system.

  In general an entity will refer to a single data concept and use a `Data Layer`, which allow them to be persisted and manipulated via Ash. Currently Ash provides Postgres and ETS (Erlang Term Storage) as Data Layers, but more are planned. Any one can create a Data Layer, either to provide support for a new database, a new storage format like CSV, or to power a custom use case like a resource that is backed by an external API.

  It is also possible to create a resource without a Data Layer, which for example could be used to provide autogemerated documentation of an API that you already made.

  Regardless of whether or not a resource is backed by data, resources are designed to contain as much of your business logic as possible in a static declaration. Resources provide opportunities to declare CRUD operations, attributes, relationships, and other behavior, all of which can be customized to map to your underlying business logic.

  Once a resource is declared, it will expose a public, standardized API that can be consumed in many different forms.

  | Consumer | Use Case |
  | :--- | :--- |
  | Business Logic | Server side code such as from Phoenix Contexts |
  | Web Layer | Full JSON:API web layer compliance via AshJsonApi and AshGraphQl |
  | Front Ends | UIs can use a schema file to know exactly how to interact web layer API |

  In your typical application using Ash, resources would be located in the `lib/resources` directory. The file name should be the single underscored name of the data that backs the resource with a `.ex` extension (ie: `lib/resources/post.ex`).

  To create a resource simply add `use Ash.Resource, ...` at the top of your resource module, and refer to the DSL
  documentation for the rest. The options for `use Ash.Resource` are described below.

  For example, here is a resource definition using Postgres:
  ```elixir
  defmodule MyApp.Post do
    use Ash.Resource, name: "post", type: "post"
    use AshPostgres, repo: MyApp.Repo
  end
  ```

  Resource DSL documentation: `Ash.Resource.DSL`

  #{Ashton.document(@resource_opts_schema, header_depth: 2, name: "Ash.Resource")}

  Note:
  *Do not* call the functions on a resource, as in `MyResource.type()` as this is a *private*
  API and can change at any time. Instead, use the `Ash` module, for example: `Ash.type(MyResource)`
  """

  defmacro __using__(opts) do
    quote do
      @before_compile Ash.Resource
      @behaviour Ash.Resource

      opts =
        case Ashton.validate(unquote(opts), Ash.Resource.resource_opts_schema()) do
          {:error, [{key, message} | _]} ->
            raise Ash.Error.ResourceDslError,
              using: __MODULE__,
              option: key,
              message: message

          {:ok, opts} ->
            opts
        end

      Ash.Resource.define_resource_module_attributes(__MODULE__, opts)
      Ash.Resource.define_primary_key(__MODULE__, opts)

      use Ash.Resource.DSL
    end
  end

  @doc false
  def define_resource_module_attributes(mod, opts) do
    Module.register_attribute(mod, :before_compile_hooks, accumulate: true)
    Module.register_attribute(mod, :actions, accumulate: true)
    Module.register_attribute(mod, :attributes, accumulate: true)
    Module.register_attribute(mod, :relationships, accumulate: true)
    Module.register_attribute(mod, :extensions, accumulate: true)
    Module.register_attribute(mod, :authorizers, accumulate: true)

    Module.put_attribute(mod, :name, opts[:name])
    Module.put_attribute(mod, :resource_type, opts[:type])
    Module.put_attribute(mod, :data_layer, nil)
    Module.put_attribute(mod, :description, nil)
  end

  @doc false
  def define_primary_key(mod, opts) do
    case opts[:primary_key] do
      true ->
        {:ok, attribute} =
          Ash.Resource.Attributes.Attribute.new(mod, :id, :uuid,
            primary_key?: true,
            default: &Ecto.UUID.generate/0,
            generated?: true
          )

        Module.put_attribute(mod, :attributes, attribute)

      false ->
        :ok

      opts ->
        {:ok, attribute} =
          Ash.Resource.Attributes.Attribute.new(mod, opts[:field], opts[:type],
            primary_key?: true,
            generated?: opts[:generated?] || true
          )

        Module.put_attribute(mod, :attributes, attribute)
    end
  end

  @doc false
  def resource_opts_schema() do
    @resource_opts_schema
  end

  defmacro __before_compile__(env) do
    quote do
      case Ash.Resource.mark_primaries(@actions) do
        {:ok, actions} ->
          @sanitized_actions actions

        {:error, {:no_primary, type}} ->
          raise Ash.Error.ResourceDslError,
            message:
              "Multiple actions of type #{type} defined, one must be designated as `primary?: true`",
            path: [:actions, type]

        {:error, {:duplicate_primaries, type}} ->
          raise Ash.Error.ResourceDslError,
            message:
              "Multiple actions of type #{type} configured as `primary?: true`, but only one action per type can be the primary",
            path: [:actions, type]
      end

      @ash_primary_key Ash.Resource.primary_key(@attributes)

      require Ash.Schema

      Ash.Schema.define_schema(@name)

      def type() do
        @resource_type
      end

      def relationships() do
        @relationships
      end

      def actions() do
        @sanitized_actions
      end

      def attributes() do
        @attributes
      end

      def primary_key() do
        @ash_primary_key
      end

      def name() do
        @name
      end

      def extensions() do
        @extensions
      end

      def data_layer() do
        @data_layer
      end

      def describe() do
        @description
      end

      def authorizers() do
        @authorizers
      end

      Enum.map(@extensions || [], fn hook_module ->
        code = hook_module.before_compile_hook(unquote(Macro.escape(env)))
        Module.eval_quoted(__MODULE__, code)
      end)
    end
  end

  @doc false
  def primary_key(attributes) do
    attributes
    |> Enum.filter(& &1.primary_key?)
    |> Enum.map(& &1.name)
  end

  @doc false
  def mark_primaries(all_actions) do
    actions =
      all_actions
      |> Enum.group_by(& &1.type)
      |> Enum.flat_map(fn {type, actions} ->
        case actions do
          [action] ->
            [%{action | primary?: true}]

          actions ->
            case Enum.count(actions, & &1.primary?) do
              0 ->
                [{:error, {:no_primary, type}}]

              1 ->
                actions

              _ ->
                [{:error, {:duplicate_primaries, type}}]
            end
        end
      end)

    Enum.find(actions, fn action -> match?({:error, _}, action) end) || {:ok, actions}
  end
end
