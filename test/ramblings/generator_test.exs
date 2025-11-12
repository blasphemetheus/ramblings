defmodule Ramblings.GeneratorTest do
  use Ramblings.DataCase

  alias Ramblings.Generator

  describe "prompts" do
    alias Ramblings.Generator.Prompt

    import Ramblings.AccountsFixtures, only: [user_scope_fixture: 0]
    import Ramblings.GeneratorFixtures

    @invalid_attrs %{text: nil, html_output: nil}

    test "list_prompts/1 returns all scoped prompts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      other_prompt = prompt_fixture(other_scope)
      assert Generator.list_prompts(scope) == [prompt]
      assert Generator.list_prompts(other_scope) == [other_prompt]
    end

    test "get_prompt!/2 returns the prompt with given id" do
      scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      other_scope = user_scope_fixture()
      assert Generator.get_prompt!(scope, prompt.id) == prompt
      assert_raise Ecto.NoResultsError, fn -> Generator.get_prompt!(other_scope, prompt.id) end
    end

    test "create_prompt/2 with valid data creates a prompt" do
      valid_attrs = %{text: "some text", html_output: "some html_output"}
      scope = user_scope_fixture()

      assert {:ok, %Prompt{} = prompt} = Generator.create_prompt(scope, valid_attrs)
      assert prompt.text == "some text"
      assert prompt.html_output == "some html_output"
      assert prompt.user_id == scope.user.id
    end

    test "create_prompt/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Generator.create_prompt(scope, @invalid_attrs)
    end

    test "update_prompt/3 with valid data updates the prompt" do
      scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      update_attrs = %{text: "some updated text", html_output: "some updated html_output"}

      assert {:ok, %Prompt{} = prompt} = Generator.update_prompt(scope, prompt, update_attrs)
      assert prompt.text == "some updated text"
      assert prompt.html_output == "some updated html_output"
    end

    test "update_prompt/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      prompt = prompt_fixture(scope)

      assert_raise MatchError, fn ->
        Generator.update_prompt(other_scope, prompt, %{})
      end
    end

    test "update_prompt/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Generator.update_prompt(scope, prompt, @invalid_attrs)
      assert prompt == Generator.get_prompt!(scope, prompt.id)
    end

    test "delete_prompt/2 deletes the prompt" do
      scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      assert {:ok, %Prompt{}} = Generator.delete_prompt(scope, prompt)
      assert_raise Ecto.NoResultsError, fn -> Generator.get_prompt!(scope, prompt.id) end
    end

    test "delete_prompt/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      assert_raise MatchError, fn -> Generator.delete_prompt(other_scope, prompt) end
    end

    test "change_prompt/2 returns a prompt changeset" do
      scope = user_scope_fixture()
      prompt = prompt_fixture(scope)
      assert %Ecto.Changeset{} = Generator.change_prompt(scope, prompt)
    end
  end
end
