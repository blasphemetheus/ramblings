defmodule RamblingsWeb.PageController do
  use RamblingsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
