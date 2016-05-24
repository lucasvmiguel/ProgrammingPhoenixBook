defmodule Rumbl.Auth do
  import Phoenix.Controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = Plug.Conn.get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] -> conn
      user = user_id && repo.get(Rumbl.User, user_id) -> Plug.Conn.assign(conn, :current_user, user)
      true -> Plug.Conn.assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> Plug.Conn.assign(:current_user, user)
    |> Plug.Conn.put_session(:user_id, user.id)
    |> Plug.Conn.configure_session(renew: true)
  end

  def login_by_username_and_pass(conn, username, password, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(password, user.password_hash) -> {:ok, login(conn, user)}
      user -> {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    Plug.Conn.configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Rumbl.Router.Helpers.page_path(conn, :index))
      |> Plug.Conn.halt
    end
  end
end
