defmodule Ash.Api do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      require Ash.Structure.Helpers
      @using_opts opts
      @extensions opts[:extensions] || []
      @before_compile Ash.Structure.Helpers
      @add_before_compile Ash.Api
      @dsl_api Ash.Structure.StructureApi
      Ash.Structure.Helpers.prepare(Ash.Structure.Api, @using_opts)
      import Ash.Structure.Syntax.Api
    end
  end

  require Ash.Structure.Interface

  Ash.Structure.Interface.def_global_accessors(Ash.Structure.Api)

  def before_compile(dsl_record) do
    quote bind_quoted: [dsl_record: dsl_record] do
      if dsl_record.interface? do
        use Ash.Api.Interface
      end
    end
  end
end
