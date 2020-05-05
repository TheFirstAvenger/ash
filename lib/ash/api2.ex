defmodule Ash.Api2 do
  defmacro __using__(opts) do
    quote location: :keep do
      require Ash.Dsl.Helpers
      @using_opts unquote(opts)
      @before_compile Ash.Dsl.Helpers

      Ash.Dsl.Helpers.prepare(Ash.Dsl.Api, @using_opts)
      import Ash.Dsl.Syntax.Api
    end
  end
end
