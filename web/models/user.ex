defmodule Rumbl.User do
  use Rumbl.Web, :model
  # defstruct [ :id, :name, :username, :password]

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps
  end

  def changeset(model, params \\ :empty) do
    # modelはUser struct
    model
    |> cast(params, ~w(name username), []) # nameとusernameは必須
    |> validate_length(:username, min: 1, max: 20)
  end
end
