defmodule Ramblings.GeneratorFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ramblings.Generator` context.
  """

  @doc """
  Generate a prompt.
  """
  def prompt_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        html_output: "some html_output",
        text: "some text"
      })

    {:ok, prompt} = Ramblings.Generator.create_prompt(scope, attrs)
    prompt
  end
end
