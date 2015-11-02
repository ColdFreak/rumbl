defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2]

  def init(opts) do
    # raise if the given key does not exist, 
    # so Rumbl.Auth will always require the `:repo` option
    Keyword.fetch!(opts, :repo)
  end

  # `call` will receive the repository from `init`
  # and see if `:user_id` stored in the session
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(Rumbl.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    # generates a new session id for the cookie
    |> configure_session(renew: true)
  end
  
  def login_by_username_and_pass(conn, username, given_pass, opts) do
    # We fetch repository from the given `opts` and lookup a user 
    # with the specified username
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    # drop the whole session at the end of the request
    configure_session(conn, drop: true)
  end
end
