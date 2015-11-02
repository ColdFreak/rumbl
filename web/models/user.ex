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
    # The `Ecto.Changeset.cast` function converts that naked map to 
    # an Ecto model, and for security purposes, limits the inbound
    # parameters to the ones you sepcify.
    |> cast(params, ~w(name username), []) # nameとusernameは必須
    |> validate_length(:username, min: 1, max: 20)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      # We first check if the changeset is valid
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        # `password_hash`をエンコードする, そして，put_changeを使って 結果をchangeset中のpassword_hashに保存
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
