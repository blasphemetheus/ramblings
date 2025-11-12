defmodule RamblingsWeb.HomepageLive do
  use RamblingsWeb, :live_view

  alias Ramblings.{Generator, LLM}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:prompt, "")
     |> assign(:generating, false)
     |> assign(:generated_html, nil)
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("update_prompt", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, :prompt, prompt)}
  end

  @impl true
  def handle_event("generate", %{"prompt" => prompt}, socket) do
    prompt = String.trim(prompt)

    if prompt == "" do
      {:noreply, assign(socket, :error, "Please enter a description for your site")}
    else
      # Start async generation
      LLM.generate_html_async(prompt, self())

      {:noreply,
       socket
       |> assign(:generating, true)
       |> assign(:error, nil)
       |> assign(:prompt, prompt)}
    end
  end

  @impl true
  def handle_event("save_and_view", _params, socket) do
    prompt = socket.assigns.prompt
    html_output = socket.assigns.generated_html
    current_scope = socket.assigns.current_scope

    case Generator.create_prompt(current_scope, %{text: prompt, html_output: html_output}) do
      {:ok, prompt_record} ->
        {:noreply, push_navigate(socket, to: ~p"/sites/#{prompt_record.id}")}

      {:error, _changeset} ->
        {:noreply, assign(socket, :error, "Failed to save your site. Please try again.")}
    end
  end

  @impl true
  def handle_event("clear", _params, socket) do
    {:noreply,
     socket
     |> assign(:prompt, "")
     |> assign(:generating, false)
     |> assign(:generated_html, nil)
     |> assign(:error, nil)}
  end

  @impl true
  def handle_info({:llm_result, :ok, html}, socket) do
    {:noreply,
     socket
     |> assign(:generating, false)
     |> assign(:generated_html, html)}
  end

  @impl true
  def handle_info({:llm_result, :error, reason}, socket) do
    {:noreply,
     socket
     |> assign(:generating, false)
     |> assign(:error, "Generation failed: #{inspect(reason)}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      <div class="max-w-4xl mx-auto px-4 py-12">
        <!-- Hero Section -->
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold text-gray-900 mb-4">
            ✨ ramblings.cc
          </h1>
          <p class="text-xl text-gray-600 mb-2">
            Describe a website. Watch it come to life.
          </p>
          <p class="text-sm text-gray-500">
            A whimsical sandbox for turning ideas into instant websites.
          </p>
        </div>

        <!-- Prompt Input -->
        <div class="bg-white rounded-2xl shadow-lg p-8 mb-8">
          <form phx-submit="generate">
            <label for="prompt" class="block text-sm font-medium text-gray-700 mb-2">
              What kind of website do you want to create?
            </label>
            <textarea
              id="prompt"
              name="prompt"
              rows="4"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
              placeholder="e.g., a personal blog about urban gardening with a green color scheme..."
              phx-change="update_prompt"
              disabled={@generating}
            ><%= @prompt %></textarea>

            <%= if @error do %>
              <div class="mt-2 text-sm text-red-600">
                <%= @error %>
              </div>
            <% end %>

            <div class="mt-4 flex gap-3">
              <button
                type="submit"
                disabled={@generating || @prompt == ""}
                class="flex-1 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
              >
                <%= if @generating do %>
                  <span class="flex items-center justify-center gap-2">
                    <svg
                      class="animate-spin h-5 w-5"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle
                        class="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        stroke-width="4"
                      >
                      </circle>
                      <path
                        class="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                      >
                      </path>
                    </svg>
                    Generating...
                  </span>
                <% else %>
                  Generate Site ✨
                <% end %>
              </button>

              <%= if @generated_html || @generating do %>
                <button
                  type="button"
                  phx-click="clear"
                  class="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Clear
                </button>
              <% end %>
            </div>
          </form>
        </div>

        <!-- Preview Section -->
        <%= if @generated_html do %>
          <div class="bg-white rounded-2xl shadow-lg p-8 mb-8">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-2xl font-bold text-gray-900">Preview</h2>
              <%= if @current_scope do %>
                <button
                  phx-click="save_and_view"
                  class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors"
                >
                  Save & View Site
                </button>
              <% else %>
                <div class="text-sm text-gray-500">
                  <a href="/users/log-in" class="text-blue-600 hover:underline">
                    Log in
                  </a>
                  to save this site
                </div>
              <% end %>
            </div>

            <div class="border-2 border-gray-200 rounded-lg overflow-hidden">
              <iframe
                srcdoc={@generated_html}
                class="w-full h-96 bg-white"
                sandbox="allow-same-origin"
                title="Generated website preview"
              >
              </iframe>
            </div>
          </div>
        <% end %>

        <!-- Features Section -->
        <%= if !@generated_html && !@generating do %>
          <div class="grid md:grid-cols-3 gap-6 mt-12">
            <div class="bg-white rounded-xl p-6 shadow-sm">
              <div class="text-3xl mb-3">🎨</div>
              <h3 class="font-semibold text-gray-900 mb-2">Instant Creation</h3>
              <p class="text-sm text-gray-600">
                Describe your vision in plain English and watch it materialize instantly.
              </p>
            </div>

            <div class="bg-white rounded-xl p-6 shadow-sm">
              <div class="text-3xl mb-3">🚀</div>
              <h3 class="font-semibold text-gray-900 mb-2">Live & Shareable</h3>
              <p class="text-sm text-gray-600">
                Every generated site is instantly live with its own URL you can share.
              </p>
            </div>

            <div class="bg-white rounded-xl p-6 shadow-sm">
              <div class="text-3xl mb-3">💡</div>
              <h3 class="font-semibold text-gray-900 mb-2">Experiment Freely</h3>
              <p class="text-sm text-gray-600">
                Try wild ideas, iterate quickly, and explore creative possibilities.
              </p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
