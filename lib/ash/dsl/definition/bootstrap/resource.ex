defmodule Ash.Dsl.Definition.Bootstrap.Resource do
  defmacro __using__(_) do
    quote do
      @before_compile unquote(__MODULE__)
      @after_compile Ash.Dsl.Definition.Bootstrap.SanitizeResource

      @description "No description"
      @attributes []
      @relationships []
      @groups []
      @upgrade_fields []
      @builder_name nil
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def name(), do: @name
      def identifier(), do: @identifier

      def default_page_size() do
        50
      end

      def max_page_size() do
        100
      end

      def data_layer(), do: Ash.DataLayer.Ets

      def description() do
        @description
      end

      def attributes() do
        @attributes
      end

      def relationships() do
        @relationships
        |> Enum.map(&Map.put(&1, :source_field, :id))
      end

      def actions() do
        [
          %{
            name: :default,
            type: :read,
            primary?: true,
            paginate?: false
          },
          %{
            name: :default,
            type: :create,
            primary?: true
          },
          %{
            name: :default,
            type: :update,
            primary?: true
          },
          %{
            name: :default,
            type: :destroy,
            primary?: true
          }
        ]
      end

      # DSL Specific
      def groups(), do: @groups
      def upgrade_fields(), do: @upgrade_fields
      def builder_name, do: @builder_name
    end
  end

  defmacro attr(name, type, keys \\ []) do
    quote bind_quoted: [name: name, type: type, keys: keys] do
      values =
        [
          name: name,
          type: type,
          allow_nil?: true,
          generated?: false,
          default: nil,
          primary_key?: false
        ]
        |> Keyword.merge(keys)

      Enum.into(values, %{})
    end
  end

  defmacro has_many(name, destination, keys \\ []) do
    quote bind_quoted: [name: name, destination: destination, keys: keys] do
      %{name: name, destination: destination, type: :has_many, cardinality: :has_many}
      |> Map.merge(Enum.into(keys, %{}))
    end
  end
end
