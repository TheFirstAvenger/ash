defmodule Ash.Test.Type.TypeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  defmodule PostTitle do
    @moduledoc false
    use Ash.Type

    def describe do
      "A post title is less than 10 characters long and is only alphabetic characters and whitespace"
    end

    def storage_type, do: :string

    def cast_input(value) when is_bitstring(value) do
      if String.length(value) <= 10 && String.match?(value, ~r/[a-zA-Z\w]*/) do
        {:ok, value}
      else
        :error
      end
    end

    def cast_input(_), do: :error

    def supported_filter_types(_data_layer), do: []
    def sortable?(_data_layer), do: false

    def cast_stored(value) when is_bitstring(value), do: value
    def cast_stored(_), do: :error

    def dump_to_native(value) when is_bitstring(value), do: value
    def dump_to_native(_), do: :error
  end

  defmodule Post do
    @moduledoc false
    use Ash.Resource, data_layer: Ash.DataLayer.Ets

    ets do
      private?(true)
    end

    attributes do
      attribute :title, PostTitle
    end

    actions do
      create :default
      read :default
    end
  end

  defmodule Api do
    @moduledoc false
    use Ash.Api

    resources do
      resource(Post)
    end
  end

  test "it accepts valid data" do
    post = Api.create!(Post, attributes: %{title: "foobar"})

    assert post.title == "foobar"
  end

  test "it rejects invalid data" do
    # As we add informative errors, this test will fail and we will know to test those
    # more informative errors.
    assert_raise(Ash.Error.Invalid, ~r/Invalid value provided for title/, fn ->
      Api.create!(Post, attributes: %{title: "foobarbazbuzbiz"})
    end)
  end

  @tag :skip
  test "it rejects filtering on the field if the filter type is not supported" do
    # As we add more filter types, we may want to test their multiplicity here
    post = Api.create!(Post, attributes: %{title: "foobar"})

    assert_raise(Ash.Error.Invalid, fn ->
      Post
      |> Api.query()
      |> Ash.Query.filter(title: post.title)
      |> Api.read!()
    end)
  end

  test "it rejects sorting on the field if sorting is not supported" do
    Api.create!(Post, attributes: %{title: "foobar1"})
    Api.create!(Post, attributes: %{title: "foobar2"})

    assert_raise(Ash.Error.Invalid, ~r/\* Cannot sort on :title/, fn ->
      Post
      |> Api.query()
      |> Ash.Query.sort(title: :asc)
      |> Api.read!()
    end)
  end
end
