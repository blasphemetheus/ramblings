defmodule RamblingsWeb.PromptLiveTest do
  use RamblingsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ramblings.GeneratorFixtures

  @create_attrs %{text: "some text", html_output: "some html_output"}
  @update_attrs %{text: "some updated text", html_output: "some updated html_output"}
  @invalid_attrs %{text: nil, html_output: nil}

  setup :register_and_log_in_user

  defp create_prompt(%{scope: scope}) do
    prompt = prompt_fixture(scope)

    %{prompt: prompt}
  end

  describe "Index" do
    setup [:create_prompt]

    test "lists all prompts", %{conn: conn, prompt: prompt} do
      {:ok, _index_live, html} = live(conn, ~p"/prompts")

      assert html =~ "Listing Prompts"
      assert html =~ prompt.text
    end

    test "saves new prompt", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/prompts")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Prompt")
               |> render_click()
               |> follow_redirect(conn, ~p"/prompts/new")

      assert render(form_live) =~ "New Prompt"

      assert form_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#prompt-form", prompt: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/prompts")

      html = render(index_live)
      assert html =~ "Prompt created successfully"
      assert html =~ "some text"
    end

    test "updates prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, ~p"/prompts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#prompts-#{prompt.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/prompts/#{prompt}/edit")

      assert render(form_live) =~ "Edit Prompt"

      assert form_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#prompt-form", prompt: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/prompts")

      html = render(index_live)
      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated text"
    end

    test "deletes prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, ~p"/prompts")

      assert index_live |> element("#prompts-#{prompt.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#prompts-#{prompt.id}")
    end
  end

  describe "Show" do
    setup [:create_prompt]

    test "displays prompt", %{conn: conn, prompt: prompt} do
      {:ok, _show_live, html} = live(conn, ~p"/prompts/#{prompt}")

      assert html =~ "Show Prompt"
      assert html =~ prompt.text
    end

    test "updates prompt and returns to show", %{conn: conn, prompt: prompt} do
      {:ok, show_live, _html} = live(conn, ~p"/prompts/#{prompt}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/prompts/#{prompt}/edit?return_to=show")

      assert render(form_live) =~ "Edit Prompt"

      assert form_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#prompt-form", prompt: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/prompts/#{prompt}")

      html = render(show_live)
      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated text"
    end
  end
end
