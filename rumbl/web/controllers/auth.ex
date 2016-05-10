defmodule Rumbl.Auth do
  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = Plug.Conn.get_session(conn, :user_id)
    user = user_id && repo.get(Rumbl.User, user_id)
    Plug.Conn.assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> Plug.Conn.assign(:current_user, user)
    |> Plug.Conn.put_session(:user_id, user.id)
    |> Plug.Conn.configure_session(renew: true)
  end
end
