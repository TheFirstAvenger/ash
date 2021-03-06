defmodule Ash.Error.Dsl.DslError do
  @moduledoc "Used when a DSL is incorrectly configured."
  defexception [:message, :path]

  def message(%{message: message, path: nil}) do
    message
  end

  def message(%{message: message, path: dsl_path}) do
    dsl_path = Enum.join(dsl_path, " -> ")
    "#{dsl_path}:\n  #{message}"
  end
end
