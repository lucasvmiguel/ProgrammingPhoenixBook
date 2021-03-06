defmodule Rumbl.VideoController do
  use Rumbl.Web, :controller

  alias Rumbl.Video

  plug :scrub_params, "video" when action in [:create, :update]
  plug :load_categories when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    videos = Repo.all(user_videos(conn.assigns.current_user))
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns.current_user
      |> build_assoc(:videos)
      |> Video.changeset

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    #changeset = Video.changeset(%Video{}, video_params)
    changeset =
      conn.assigns.current_user
      |> build_assoc(:videos)
      |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    video = Repo.get!(user_videos(conn.assigns.current_user), id)
      |> Repo.preload(:user)
      |> Repo.preload(:category)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}) do
    video = Repo.get!(user_videos(conn.assigns.current_user), id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}) do
    video = Repo.get!(user_videos(conn.assigns.current_user), id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    video = Repo.get!(user_videos(conn.assigns.current_user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp user_videos(user) do
    Ecto.assoc(user, :videos)
  end

  defp load_categories(conn, _) do
    query =
      Rumbl.Category
      |> Rumbl.Category.alphabetical
      |> Rumbl.Category.names_and_ids

    categories = Repo.all query
    assign(conn, :categories, categories)
  end
end
