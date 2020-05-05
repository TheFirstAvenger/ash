defmodule Ash.Resource2 do
  defmacro __using__(opts) do
    quote location: :keep do
      require Ash.Dsl.Helpers
      @using_opts unquote(opts)
      @add_before_compile Ash.Resource2
      @before_compile Ash.Dsl.Helpers
      Ash.Dsl.Helpers.prepare(Ash.Dsl.Resource, @using_opts)
      import Ash.Dsl.Syntax.Resource
    end
  end
end
