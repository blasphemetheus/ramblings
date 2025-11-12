defmodule Ramblings.Generator.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "prompts" do
    field :text, :string
    field :html_output, :string
    belongs_to :user, Ramblings.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(prompt, attrs, user_scope) do
    prompt
    |> cast(attrs, [:text, :html_output])
    |> validate_required([:text, :html_output])
    |> put_change(:user_id, user_scope.user.id)
  end
end
