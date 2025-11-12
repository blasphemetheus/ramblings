defmodule RamblingsWeb.ExploreLive do
  use RamblingsWeb, :live_view

  alias Ramblings.Generator

  @impl true
  def mount(_params, _session, socket) do
    # Get recent public sites (for now, just all recent sites)
    # In production, you'd add a "public" flag to prompts
    prompts = Generator.list_recent_prompts(20)

    {:ok,
     socket
     |> assign(:prompts, prompts)
     |> assign(:page_title, "Explore")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Explore</h1>
        <p class="text-gray-600 mt-1">Discover recently generated websites from the community</p>
      </div>

      <%= if Enum.empty?(@prompts) do %>
        <div class="bg-white rounded-xl shadow-sm p-12 text-center">
          <div class="text-6xl mb-4">🔍</div>
          <h2 class="text-xl font-semibold text-gray-900 mb-2">No sites to explore yet</h2>
          <p class="text-gray-600 mb-6">
            Be the first to create a website!
          </p>
          <.link
            navigate={~p"/"}
            class="inline-block bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
          >
            Create a Site
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

                <div class="flex items-center justify-between text-xs text-gray-500">
                  <span>
                    <%= Calendar.strftime(prompt.inserted_at, "%b %d, %Y") %>
                  </span>
                  <.link
                    navigate={~p"/sites/#{prompt.id}"}
                    class="text-blue-600 hover:text-blue-700 font-medium"
                  >
                    View →
                  </.link>
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
