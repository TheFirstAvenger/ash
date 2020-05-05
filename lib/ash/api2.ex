defmodule Ash.Api2 do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      require Ash.Dsl.Helpers
      @using_opts opts
      @extensions opts[:extensions] || []
      @before_compile Ash.Dsl.Helpers

      Ash.Dsl.Helpers.prepare(Ash.Dsl.Api, @using_opts)
      import Ash.Dsl.Syntax.Api
    end
  end

  require Ash.Dsl.Helpers

  Ash.Dsl.Helpers.def_global_accessors(Ash.Dsl.Api)
end
