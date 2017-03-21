defmodule TheBestory.Web.PageController do
  use TheBestory.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
