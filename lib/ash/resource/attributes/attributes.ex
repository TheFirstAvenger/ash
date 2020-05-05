defmodule Ash.Resource.Attributes do
  @moduledoc """
  A DSL component for declaring attributes

  Attributes are fields on an instance of a resource. The two required
  pieces of knowledge are the field name, and the type.
  """

  @doc false
  defmacro attributes(do: block) do
    quote location: :keep do
      import Ash.Resource.Attributes
      import Ash.Authorization.Check.BuiltInChecks
      import Ash.Authorization.Check.AttributeBuiltInChecks

      unquote(block)

      import Ash.Resource.Attributes, only: [attributes: 1]
      import Ash.Authorization.Check.BuiltInChecks, only: []
      import Ash.Authorization.Check.AttributeBuiltInChecks, only: []
    end
  end

  @doc """
  Declares an attribute on the resource

  Type can be either a built in type (see `Ash.Type`) for more, or a module
  implementing the `Ash.Type` behaviour.

  #{Ashton.document(Ash.Resource.Attributes.Attribute.attribute_schema(), header_depth: 2)}

  ## Examples
  ```elixir
  attribute :first_name, :string, primary_key?: true
  ```
  """
  defmacro attribute(name, type, opts \\ []) do
    quote bind_quoted: [type: type, name: name, opts: opts], location: :keep do
      unless is_atom(name) do
        raise Ash.Error.ResourceDslError,
          message: "Attribute name must be an atom, got: #{inspect(name)}",
          path: [:attributes, :attribute]
      end

      unless is_atom(type) do
        raise Ash.Error.ResourceDslError,
          message:
            "Attribute type must be a built in type or a type module, got: #{inspect(type)}",
          path: [:attributes, :attribute, name]
      end

      type = Ash.Type.get_type(type)

      unless type in Ash.Type.builtins() or Ash.Type.ash_type?(type) do
        raise Ash.Error.ResourceDslError,
          message:
            "Attribute type must be a built in type or a type module, got: #{inspect(type)}",
          path: [:attributes, :attribute, name]
      end

      case Ash.Resource.Attributes.Attribute.new(__MODULE__, name, type, opts) do
        {:ok, attribute} ->
          @attributes attribute

        {:error, [{key, message} | _]} ->
          raise Ash.Error.ResourceDslError,
            message: message,
            path: [:attributes, :attribute],
            option: key
      end
    end
  end

  @timestamp_schema Ashton.schema(
                      opts: [
                        inserted_at_field: :atom,
                        updated_at_field: :atom
                      ],
                      defaults: [
                        inserted_at_field: :inserted_at,
                        updated_at_field: :updated_at
                      ],
                      describe: [
                        inserted_at_field: "Changes the name of the inserted_at field",
                        updated_at_field: "Changes the name of the updated_at field"
                      ]
                    )

  @doc """
  Adds auto updating timestamp fields

  The field names default to `:inserted_at` and `:updated_at`, but can be overwritten via
  passing overrides in the opts, e.g `timestamps(inserted_at: :created_at, updated_at: :last_touched)

  #{Ashton.document(@timestamp_schema, header_depth: 2)}

  ## Examples
  ```elixir
  attribute :first_name, :string, primary_key?: true
  ```
  """
  defmacro timestamps(opts \\ []) do
    opts =
      case Ashton.validate(opts, @timestamp_schema) do
        {:ok, opts} ->
          opts

        {:error, [{key, message} | _]} ->
          raise Ash.Error.ApiDslError,
            message: message,
            path: [:attributes, :timestamps],
            option: key,
            message: message
      end

    quote bind_quoted: [opts: opts], location: :keep do
      inserted_at_name = opts[:inserted_at_field]
      updated_at_name = opts[:updated_at_field]

      attribute(inserted_at_name, :utc_datetime, generated?: true, default: &DateTime.utc_now/0)

      attribute(updated_at_name, :utc_datetime,
        generated?: true,
        default: &DateTime.utc_now/0,
        update_default: &DateTime.utc_now/0
      )
    end
  end
end
