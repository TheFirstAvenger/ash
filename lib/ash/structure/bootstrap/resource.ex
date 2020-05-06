defmodule Ash.Structure.Bootstrap.Resource do
  defmacro __using__(_) do
    quote do
      def name(), do: @name
      def identifier(), do: @identifier

      def default_page_size() do
        50
      end

      def max_page_size() do
        100
      end

      defp get_attr(attr, default) do
        Module.get_attribute(__MODULE__, attr, default)
      end

      def data_layer(), do: Ash.DataLayer.Ets

      def description() do
        get_attr(:description, "No description")
      end

      def attributes() do
        get_attr(:attributes, [])
      end

      def relationships() do
        get_attr(:relationships, [])
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
      def groups(), do: get_attr(:groups, [])
      def upgrade_fields(), do: get_attr(:upgrade_fields, [])
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

  defmacro has_many(name, destination) do
    quote bind_quoted: [name: name, destination: destination] do
      %{name: name, destination: destination, type: :has_many, cardinality: :has_many}
    end
  end
end
