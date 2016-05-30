defmodule Rumbl.WatchController do
  use Rumbl.Web, :controller

  def show(conn, %{"id" => id}) do
    video = Repo.get!(Rumbl.Video, id)
    render(conn, "show.html", video: video)
  end
end
