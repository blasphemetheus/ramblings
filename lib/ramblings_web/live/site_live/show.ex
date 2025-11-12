defmodule RamblingsWeb.SiteLive.Show do
  use RamblingsWeb, :live_view

  alias Ramblings.Generator

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Generator.get_prompt(id, socket.assigns.current_scope) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Site not found")
         |> push_navigate(to: ~p"/")}

      prompt ->
        {:ok,
         socket
         |> assign(:prompt, prompt)
         |> assign(:page_title, "Generated Site")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Header Bar -->
      <div class="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div class="max-w-7xl mx-auto px-4 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <.link navigate={~p"/"} class="text-blue-600 hover:text-blue-700 font-medium">
                ← Back
              </.link>
              <div class="border-l border-gray-300 pl-4">
                <h1 class="text-lg font-semibold text-gray-900">Generated Site</h1>
                <p class="text-sm text-gray-500">
                  Created <%= Calendar.strftime(@prompt.inserted_at, "%b %d, %Y") %>
                </p>
              </div>
            </div>

            <div class="flex gap-2">
              <%= if @current_scope && @current_scope.user.id == @prompt.user_id do %>
                <.link
                  navigate={~p"/prompts/#{@prompt}/edit"}
                  class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors text-sm"
                >
                  Edit
                </.link>
              <% end %>

              <button
                onclick="window.open(window.location.href + '/fullscreen', '_blank')"
                class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors text-sm"
              >
                Open in New Tab
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Prompt Display -->
      <div class="max-w-7xl mx-auto px-4 py-6">
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <h2 class="text-sm font-semibold text-blue-900 mb-2">Original Prompt:</h2>
          <p class="text-blue-800"><%= @prompt.text %></p>
        </div>

        <!-- Site Preview -->
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
          <div class="border-b border-gray-200 bg-gray-50 px-4 py-2 flex items-center gap-2">
            <div class="flex gap-1.5">
              <div class="w-3 h-3 rounded-full bg-red-400"></div>
              <div class="w-3 h-3 rounded-full bg-yellow-400"></div>
              <div class="w-3 h-3 rounded-full bg-green-400"></div>
            </div>
            <div class="flex-1 flex justify-center">
              <div class="bg-white px-4 py-1 rounded text-xs text-gray-600 font-mono">
                ramblings.cc/sites/<%= @prompt.id %>
              </div>
            </div>
          </div>

          <iframe
            srcdoc={@prompt.html_output}
            class="w-full border-0"
            style="height: calc(100vh - 300px); min-height: 600px;"
            sandbox="allow-same-origin"
            title="Generated website"
          >
          </iframe>
        </div>
      </div>
    </div>
    """
  end
end
