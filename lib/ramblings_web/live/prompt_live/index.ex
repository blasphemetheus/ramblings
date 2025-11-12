defmodule RamblingsWeb.PromptLive.Index do
  use RamblingsWeb, :live_view

  alias Ramblings.Generator

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Prompts
        <:actions>
          <.button variant="primary" navigate={~p"/prompts/new"}>
            <.icon name="hero-plus" /> New Prompt
          </.button>
        </:actions>
      </.header>

      <.table
        id="prompts"
        rows={@streams.prompts}
        row_click={fn {_id, prompt} -> JS.navigate(~p"/prompts/#{prompt}") end}
      >
        <:col :let={{_id, prompt}} label="Text">{prompt.text}</:col>
        <:col :let={{_id, prompt}} label="Html output">{prompt.html_output}</:col>
        <:action :let={{_id, prompt}}>
          <div class="sr-only">
            <.link navigate={~p"/prompts/#{prompt}"}>Show</.link>
          </div>
          <.link navigate={~p"/prompts/#{prompt}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, prompt}}>
          <.link
            phx-click={JS.push("delete", value: %{id: prompt.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Generator.subscribe_prompts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Prompts")
     |> stream(:prompts, list_prompts(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prompt = Generator.get_prompt!(socket.assigns.current_scope, id)
    {:ok, _} = Generator.delete_prompt(socket.assigns.current_scope, prompt)

    {:noreply, stream_delete(socket, :prompts, prompt)}
  end

  @impl true
  def handle_info({type, %Ramblings.Generator.Prompt{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :prompts, list_prompts(socket.assigns.current_scope), reset: true)}
  end

  defp list_prompts(current_scope) do
    Generator.list_prompts(current_scope)
  end
end
