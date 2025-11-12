defmodule RamblingsWeb.PromptLive.Form do
  use RamblingsWeb, :live_view

  alias Ramblings.Generator
  alias Ramblings.Generator.Prompt

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage prompt records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="prompt-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:text]} type="text" label="Text" />
        <.input field={@form[:html_output]} type="textarea" label="Html output" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Prompt</.button>
          <.button navigate={return_path(@current_scope, @return_to, @prompt)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    prompt = Generator.get_prompt!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Prompt")
    |> assign(:prompt, prompt)
    |> assign(:form, to_form(Generator.change_prompt(socket.assigns.current_scope, prompt)))
  end

  defp apply_action(socket, :new, _params) do
    prompt = %Prompt{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Prompt")
    |> assign(:prompt, prompt)
    |> assign(:form, to_form(Generator.change_prompt(socket.assigns.current_scope, prompt)))
  end

  @impl true
  def handle_event("validate", %{"prompt" => prompt_params}, socket) do
    changeset = Generator.change_prompt(socket.assigns.current_scope, socket.assigns.prompt, prompt_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"prompt" => prompt_params}, socket) do
    save_prompt(socket, socket.assigns.live_action, prompt_params)
  end

  defp save_prompt(socket, :edit, prompt_params) do
    case Generator.update_prompt(socket.assigns.current_scope, socket.assigns.prompt, prompt_params) do
      {:ok, prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, prompt)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_prompt(socket, :new, prompt_params) do
    case Generator.create_prompt(socket.assigns.current_scope, prompt_params) do
      {:ok, prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, prompt)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _prompt), do: ~p"/prompts"
  defp return_path(_scope, "show", prompt), do: ~p"/prompts/#{prompt}"
end
