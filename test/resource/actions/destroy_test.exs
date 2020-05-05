defmodule Ash.Test.Dsl.Resource.Actions.DestroyTest do
  use ExUnit.Case, async: true

  defmacrop defposts(do: body) do
    quote location: :keep do
      defmodule Post do
        use Ash.Resource, name: "posts", type: "post", primary_key: false

        unquote(body)
      end
    end
  end

  describe "representation" do
    test "it creates an action" do
      defposts do
        actions do
          destroy :default
        end
      end

      assert [
               %Ash.Resource.Actions.Destroy{
                 name: :default,
                 primary?: true,
                 rules: [],
                 type: :destroy
               }
             ] = Ash.actions(Post)
    end
  end

  describe "validation" do
    test "it fails if `name` is not an atom" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "action name must be an atom at actions -> destroy",
        fn ->
          defposts do
            actions do
              destroy "default"
            end
          end
        end
      )
    end

    test "it fails if `primary?` is not a boolean" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option primary? at actions -> destroy -> default must be boolean",
        fn ->
          defposts do
            actions do
              destroy :default, primary?: 10
            end
          end
        end
      )
    end

    test "it fails if `rules` is not a list" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option rules at actions -> destroy -> default must be keyword",
        fn ->
          defposts do
            actions do
              destroy :default, rules: 10
            end
          end
        end
      )
    end
  end
end
