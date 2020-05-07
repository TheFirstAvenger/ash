defmodule Ash.Api do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      # require Ash.Dsl.Definition.Helpers
      # @using_opts opts
      # @extensions opts[:extensions] || []
      # @before_compile Ash.Dsl.Definition.Helpers
      # @add_before_compile Ash.Api
      # @dsl_api Ash.Dsl.Definition.StructureApi
      # Ash.Dsl.Definition.Helpers.prepare(Ash.Dsl.Definition.Api, @using_opts)
      # import Ash.Dsl.Definition.Syntax.Api
    end
  end

  # require Ash.Dsl.Definition.Interface

  # Ash.Dsl.Definition.Interface.def_global_accessors(Ash.Dsl.Definition.Api)

  # def before_compile(dsl_record) do
  #   quote bind_quoted: [dsl_record: dsl_record] do
  #     if dsl_record.interface? do
  #       use Ash.Api.Interface
  #     end
  #   end
  # end
end
