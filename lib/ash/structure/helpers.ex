defmodule Ash.Structure.Helpers do
  defmacro __before_compile__(_env) do
    quote bind_quoted: [], location: :keep do
      attrs =
        @attributes
        |> Kernel.||([])
        |> Enum.into(%{})
        |> Map.put(:id, @resource_id)

      attrs =
        Enum.reduce(@using_opts, attrs, fn {key, value}, attrs ->
          Map.put(attrs, key, value)
        end)

      {:ok, record} = @dsl_api.create(@dsl_resource, attributes: attrs)

      record =
        case Module.get_attribute(__MODULE__, :process_record) do
          nil ->
            record

          process_record ->
            process_record.process_record(record)
        end

      case Module.get_attribute(__MODULE__, :add_before_compile) do
        nil ->
          :ok

        module ->
          Code.eval_quoted(module.before_compile(record), [], __ENV__)
      end

      require Ash.Structure.Interface
      Ash.Structure.Interface.def_accessors(record)
    end
  end

  defmacro prepare(dsl_resource, _opts) do
    quote bind_quoted: [dsl_resource: dsl_resource],
          location: :keep do
      @dsl_resource dsl_resource
      @resource_id Ecto.UUID.generate()

      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
    end
  end
end
