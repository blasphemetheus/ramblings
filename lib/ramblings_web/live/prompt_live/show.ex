defmodule RamblingsWeb.PromptLive.Show do
  use RamblingsWeb, :live_view

  alias Ramblings.Generator

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Prompt {@prompt.id}
        <:subtitle>This is a prompt record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/prompts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/prompts/#{@prompt}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit prompt
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Text">{@prompt.text}</:item>
        <:item title="Html output">{@prompt.html_output}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Generator.subscribe_prompts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Prompt")
     |> assign(:prompt, Generator.get_prompt!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Ramblings.Generator.Prompt{id: id} = prompt},
        %{assigns: %{prompt: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :prompt, prompt)}
  end

  def handle_info(
        {:deleted, %Ramblings.Generator.Prompt{id: id}},
        %{assigns: %{prompt: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current prompt was deleted.")
     |> push_navigate(to: ~p"/prompts")}
  end

  def handle_info({type, %Ramblings.Generator.Prompt{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
