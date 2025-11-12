defmodule RamblingsWeb.MySitesLive do
  use RamblingsWeb, :live_view

  alias Ramblings.Generator

  @impl true
  def mount(_params, _session, socket) do
    current_scope = socket.assigns.current_scope
    prompts = Generator.list_prompts(current_scope)

    {:ok,
     socket
     |> assign(:prompts, prompts)
     |> assign(:page_title, "My Sites")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prompt = Generator.get_prompt(id, socket.assigns.current_scope)

    case Generator.delete_prompt(prompt, socket.assigns.current_scope) do
      {:ok, _} ->
        prompts = Generator.list_prompts(socket.assigns.current_scope)

        {:noreply,
         socket
         |> assign(:prompts, prompts)
         |> put_flash(:info, "Site deleted successfully")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete site")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">My Sites</h1>
          <p class="text-gray-600 mt-1">All your generated websites</p>
        </div>
        <.link
          navigate={~p"/"}
          class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
        >
          + Create New Site
        </.link>
      </div>

      <%= if Enum.empty?(@prompts) do %>
        <div class="bg-white rounded-xl shadow-sm p-12 text-center">
          <div class="text-6xl mb-4">🌀</div>
          <h2 class="text-xl font-semibold text-gray-900 mb-2">No sites yet</h2>
          <p class="text-gray-600 mb-6">
            Start by creating your first website from a simple description.
          </p>
          <.link
            navigate={~p"/"}
            class="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
          >
            Create Your First Site
          </.link>
        </div>
      <% else %>
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for prompt <- @prompts do %>
            <div class="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow overflow-hidden border border-gray-200">
              <!-- Preview Thumbnail -->
              <div class="bg-gray-50 border-b border-gray-200 relative group">
                <iframe
                  srcdoc={prompt.html_output}
                  class="w-full h-48 pointer-events-none"
                  sandbox=""
                  title={"Preview of #{prompt.text}"}
                >
                </iframe>
                <div class="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end justify-center pb-4">
                  <.link
                    navigate={~p"/sites/#{prompt.id}"}
                    class="bg-white text-gray-900 px-4 py-2 rounded-lg font-medium hover:bg-gray-100 transition-colors"
                  >
                    View Site →
                  </.link>
                </div>
              </div>

              <!-- Info -->
              <div class="p-4">
                <p class="text-sm text-gray-700 mb-3 line-clamp-2">
                  <%= prompt.text %>
                </p>

                <div class="flex items-center justify-between text-xs text-gray-500 mb-3">
                  <span>
                    <%= Calendar.strftime(prompt.inserted_at, "%b %d, %Y") %>
                  </span>
                  <span class="text-gray-400">•</span>
                  <span>
                    <%= Calendar.strftime(prompt.inserted_at, "%I:%M %p") %>
                  </span>
                </div>

                <div class="flex gap-2">
                  <.link
                    navigate={~p"/sites/#{prompt.id}"}
                    class="flex-1 text-center px-3 py-2 bg-blue-50 text-blue-700 rounded-lg hover:bg-blue-100 transition-colors text-sm font-medium"
                  >
                    View
                  </.link>
                  <.link
                    navigate={~p"/prompts/#{prompt.id}/edit"}
                    class="flex-1 text-center px-3 py-2 bg-gray-50 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors text-sm font-medium"
                  >
                    Edit
                  </.link>
                  <button
                    phx-click="delete"
                    phx-value-id={prompt.id}
                    data-confirm="Are you sure you want to delete this site?"
                    class="px-3 py-2 bg-red-50 text-red-700 rounded-lg hover:bg-red-100 transition-colors text-sm font-medium"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
