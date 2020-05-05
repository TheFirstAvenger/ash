defmodule Ash.Resource.ResourceHelpers do
  @doc false
  def define_primary_key(mod, opts) do
    case Module.get_attribute(mod, :primary_key) do
      nil ->
        {:ok, attribute} =
          Ash.Resource.Attributes.Attribute.new(mod, :id, :uuid,
            primary_key?: true,
            default: &Ecto.UUID.generate/0,
            generated?: true,
            write_rules: false
          )

        Module.put_attribute(mod, :attributes, attribute)

      false ->
        :ok

      %{field: field, type: type} ->
        {:ok, attribute} =
          Ash.Resource.Attributes.Attribute.new(mod, field, type,
            primary_key?: true,
            generated?: opts[:generated?] || true,
            write_rules: false
          )

        Module.put_attribute(mod, :attributes, attribute)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      # case Ash.Resource.mark_primaries(@actions) do
      #   {:ok, actions} ->
      #     @sanitized_actions actions

      #   {:error, {:no_primary, type}} ->
      #     raise Ash.Error.ResourceDslError,
      #       message:
      #         "Multiple actions of type #{type} defined, one must be designated as `primary?: true`",
      #       path: [:actions, type]

      #   {:error, {:duplicate_primaries, type}} ->
      #     raise Ash.Error.ResourceDslError,
      #       message:
      #         "Multiple actions of type #{type} configured as `primary?: true`, but only one action per type can be the primary",
      #       path: [:actions, type]
      # end
      @ash_primary_key Ash.Resource.primary_key(@attributes)

      require Ash.Schema

      # Ash.Schema.define_schema(@name)

      # def primary_key() do
      #   @ash_primary_key
      # end

      # def data_layer() do
      #   @data_layer
      # end

      # def mix_ins() do
      #   @mix_ins
      # end

      # Enum.map(@mix_ins || [], fn hook_module ->
      #   code = hook_module.before_compile_hook(unquote(Macro.escape(env)))
      #   Module.eval_quoted(__MODULE__, code)
      # end)
    end
  end

  defmacro def_getter(attribute_name, default) do
    quote bind_quoted: [attribute_name: attribute_name, default: default], location: :keep do
      case Module.get_attribute(__MODULE__, attribute_name) do
        nil ->
          case default do
            {:constant, value} ->
              def unquote(attribute_name)() do
                unquote(value)
              end

            nil ->
              def unquote(attribute_name)() do
                nil
              end
          end

        value ->
          def unquote(attribute_name)() do
            unquote(value)
          end
      end
    end
  end
end
