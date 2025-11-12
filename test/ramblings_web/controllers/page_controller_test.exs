defmodule RamblingsWeb.PageControllerTest do
  use RamblingsWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "ramblings.cc"
    assert html =~ "Describe a website. Watch it come to life."
  end
end
