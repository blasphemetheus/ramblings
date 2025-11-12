defmodule Ramblings.Generator do
  @moduledoc """
  The Generator context.
  """

  import Ecto.Query, warn: false
  alias Ramblings.Repo

  alias Ramblings.Generator.Prompt
  alias Ramblings.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any prompt changes.

  The broadcasted messages match the pattern:

    * {:created, %Prompt{}}
    * {:updated, %Prompt{}}
    * {:deleted, %Prompt{}}

  """
  def subscribe_prompts(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Ramblings.PubSub, "user:#{key}:prompts")
  end

  defp broadcast_prompt(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Ramblings.PubSub, "user:#{key}:prompts", message)
  end

  @doc """
  Returns the list of prompts.

  ## Examples

      iex> list_prompts(scope)
      [%Prompt{}, ...]

  """
  def list_prompts(%Scope{} = scope) do
    Repo.all_by(Prompt, user_id: scope.user.id)
  end

  @doc """
  Gets a single prompt.

  Raises `Ecto.NoResultsError` if the Prompt does not exist.

  ## Examples

      iex> get_prompt!(scope, 123)
      %Prompt{}

      iex> get_prompt!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_prompt!(%Scope{} = scope, id) do
    Repo.get_by!(Prompt, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a prompt.

  ## Examples

      iex> create_prompt(scope, %{field: value})
      {:ok, %Prompt{}}

      iex> create_prompt(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prompt(%Scope{} = scope, attrs) do
    with {:ok, prompt = %Prompt{}} <-
           %Prompt{}
           |> Prompt.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_prompt(scope, {:created, prompt})
      {:ok, prompt}
    end
  end

  @doc """
  Updates a prompt.

  ## Examples

      iex> update_prompt(scope, prompt, %{field: new_value})
      {:ok, %Prompt{}}

      iex> update_prompt(scope, prompt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prompt(%Scope{} = scope, %Prompt{} = prompt, attrs) do
    true = prompt.user_id == scope.user.id

    with {:ok, prompt = %Prompt{}} <-
           prompt
           |> Prompt.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_prompt(scope, {:updated, prompt})
      {:ok, prompt}
    end
  end

  @doc """
  Deletes a prompt.

  ## Examples

      iex> delete_prompt(scope, prompt)
      {:ok, %Prompt{}}

      iex> delete_prompt(scope, prompt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prompt(%Scope{} = scope, %Prompt{} = prompt) do
    true = prompt.user_id == scope.user.id

    with {:ok, prompt = %Prompt{}} <-
           Repo.delete(prompt) do
      broadcast_prompt(scope, {:deleted, prompt})
      {:ok, prompt}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prompt changes.

  ## Examples

      iex> change_prompt(scope, prompt)
      %Ecto.Changeset{data: %Prompt{}}

  """
  def change_prompt(%Scope{} = scope, %Prompt{} = prompt, attrs \\ %{}) do
    true = prompt.user_id == scope.user.id

    Prompt.changeset(prompt, attrs, scope)
  end
end
