defmodule Ash.Error.Filter.UnsupportedPredicate do
  @moduledoc "Used when the datalayer does not support a provided predicate"
  use Ash.Error

  def_ash_error([:resource, :predicate, :type], class: :invalid)

  defimpl Ash.ErrorKind do
    def id(_), do: Ecto.UUID.generate()

    def code(_), do: "unsupported_predicate"

    def class(_), do: :invalid

    def message(%{resource: resource, predicate: predicate, type: type}) do
      "Data layer for #{inspect(resource)} does not support #{inspect(predicate)} for #{
        inspect(type)
      }"
    end

    def stacktrace(_), do: nil
  end
end