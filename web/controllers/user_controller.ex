defmodule Rumbl.UserController do
  use Rumbl.Web, :controller

  def new(conn, _params) do
    changeset = Rumbl.User.changeset(%Rumbl.User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = Rumbl.User.changeset(%Rumbl.User{}, user_params)
    {:ok, user} = Repo.insert(changeset)

    conn
    # push_flashは画面上に一回しか表示しない
    # https://gyazo.com/67327c75a6fa85c43cba01ac0b752b20
    |> put_flash(:info, "#{user.name} created!")
    |> redirect(to: user_path(conn, :index))
  end

  def index(conn, _params) do
    users = Repo.all(Rumbl.User)
    #    IO.puts "users = #{inspect users}"
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Rumbl.User, id)
    IO.puts "user = #{inspect user}"
    render conn, "show.html", user: user
  end
end
