defmodule AquamarineWeb.PageController do
  use AquamarineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
