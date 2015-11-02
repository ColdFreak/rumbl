defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  # 関数Plug, indexとshow関数に対して，authenticateを適応する
  # For each plug, we invode it with the given options, check if
  # the returned connection halted, and we move forward if it did not
  plug :authenticate when action in [:index, :show]

  def new(conn, _params) do
    changeset = Rumbl.User.changeset(%Rumbl.User{})
    render conn, "new.html", changeset: changeset
  end

  # we use pattern matching to pick off the user_params from the inbound form
  def create(conn, %{"user" => user_params}) do
    # we create a changeset
    changeset = Rumbl.User.registration_changeset(%Rumbl.User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        # push_flashは画面上に一回しか表示しない
        # https://gyazo.com/67327c75a6fa85c43cba01ac0b752b20
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      # insertエラーの場合
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def index(conn, _params) do
    users = Repo.all(Rumbl.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Rumbl.User, id)
    render conn, "show.html", user: user
  end

    # if there is a current user, we return the connection
  # unchanged
  # 3行目でplugに使うので，`_opts`を追加した
  defp authenticate(conn, _opts) do
    # ログインしているかを判断
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      # halts the Plug pipeline by preventing further plugs downstream from being invoked
      |> halt()
    end
  end
end
