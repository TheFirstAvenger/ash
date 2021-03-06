defmodule Ash.Error.Unknown do
  @moduledoc "The top level unknown error container"
  use Ash.Error

  def_ash_error([:errors, :error], class: :unknown)

  defimpl Ash.ErrorKind do
    def id(_), do: Ecto.UUID.generate()

    def code(_), do: "unknown"

    def message(%{errors: errors, error: error, path: path}) when not is_nil(errors) do
      custom_prefix =
        if path && path != [] do
          inspect(path) <> " - "
        else
          ""
        end

      custom_message =
        error
        |> List.wrap()
        |> Enum.map(fn message ->
          custom_prefix <> inspect(message)
        end)

      Ash.Error.error_messages(errors, custom_message)
    end
  end
end
