defmodule Ash.Test.Actions.DestroyTest do
  @moduledoc false
  use ExUnit.Case, async: true

  defmodule Profile do
    @moduledoc false
    use Ash.Resource, data_layer: Ash.DataLayer.Ets

    ets do
      private?(true)
    end

    actions do
      read :default
      create :default
      update :default
      destroy :default
    end

    attributes do
      attribute :id, :uuid, primary_key?: true, default: &Ecto.UUID.generate/0
      attribute :bio, :string
    end

    relationships do
      belongs_to :author, Ash.Test.Actions.CreateTest.Author
    end
  end

  defmodule Author do
    @moduledoc false
    use Ash.Resource, data_layer: Ash.DataLayer.Ets

    ets do
      private?(true)
    end

    actions do
      read :default
      create :default
      update :default
      destroy :default
    end

    attributes do
      attribute :id, :uuid, primary_key?: true, default: &Ecto.UUID.generate/0
      attribute :name, :string
    end

    relationships do
      has_one :profile, Profile, destination_field: :author_id

      has_many :posts, Ash.Test.Actions.CreateTest.Post, destination_field: :author_id
    end
  end

  defmodule PostDefaults do
    @moduledoc false
    def garbage2, do: "garbage2"
    def garbage3, do: "garbage3"
  end

  defmodule Post do
    @moduledoc false
    use Ash.Resource, data_layer: Ash.DataLayer.Ets

    ets do
      private?(true)
    end

    actions do
      read :default
      create :default
      update :default
      destroy :default
    end

    attributes do
      attribute :id, :uuid, primary_key?: true, default: &Ecto.UUID.generate/0
      attribute :title, :string
      attribute :contents, :string
      attribute :tag, :string, default: {:constant, "garbage"}
      attribute :tag2, :string, default: &PostDefaults.garbage2/0
      attribute :tag3, :string, default: {PostDefaults, :garbage3, []}
    end

    relationships do
      belongs_to :author, Author
    end
  end

  defmodule Api do
    @moduledoc false
    use Ash.Api

    resources do
      resource(Author)
      resource(Post)
      resource(Profile)
    end
  end

  describe "simple destroy" do
    test "allows destroying a record" do
      post = Api.create!(Post, attributes: %{title: "foo", contents: "bar"})

      assert Api.destroy!(post) == :ok

      refute Api.get!(Post, post.id)
    end
  end
end
