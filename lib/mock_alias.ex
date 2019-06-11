defmodule MockPathAlias do
  @app Mix.Project.config()[:app]

  defmacro __using__(_) do
    quote do
      import MockPathAlias
    end
  end

  defmacro mock_alias(ast_mock_alias, opts \\ [])

  defmacro mock_alias(ast_mock_alias, opts) do
    Mix.env()
    |> do_mock_alias(ast_mock_alias, __CALLER__, opts)
    |> expand_macros(opts)
  end

  # alias Foo.Bar.Buzz, as: BuzzBarFoo
  # alias Foo.Bar.Buzz
  def do_mock_alias(:test, {:__aliases__, _, _} = ast_mock_alias, env, _opts) do
    mock_alias = Macro.expand(ast_mock_alias, env)

    {_, new_mocked_alias} =
      @app
      |> Application.get_env(:mock_alias)
      |> Enum.find({nil, nil}, &(elem(&1, 0) == mock_alias))

    validate(new_mocked_alias, mock_alias)

    [new_mocked_alias]
  end

  # alias Foo.Bar.{Baz, Buzz}
  def do_mock_alias(:test, ast_mock_aliases, _env, _opts) do
    {{:., _, [{_, _, root_path}, :{}]}, _, aliases} = ast_mock_aliases

    pairs_with_mock_aliases = @app |> Application.get_env(:mock_alias)

    Enum.map(aliases, fn {_, _, each_alias} ->
      mock_alias = Module.concat(root_path ++ each_alias)

      {_, new_mocked_alias} =
        pairs_with_mock_aliases
        |> Enum.find({nil, nil}, &(elem(&1, 0) === mock_alias))

      validate(new_mocked_alias, mock_alias)

      new_mocked_alias
    end)
  end

  def do_mock_alias(_, mock_alias), do: [mock_alias]

  defp validate(new_mocked_alias, target_mock_alias) do
    unless new_mocked_alias !== nil do
      raise "declare mocked alias for the #{inspect(target_mock_alias)}"
    end

    unless target_mock_alias.__info__(:functions) === new_mocked_alias.__info__(:functions) do
      raise "declare mocking function(s) for the #{inspect(new_mocked_alias)} module"
    end
  end

  defp expand_macros(mocked_alias, opts) do
    Enum.map(mocked_alias, &expand_macro(&1, opts))
  end

  defp expand_macro(mocked_alias, []) do
    quote do: alias(unquote(mocked_alias))
  end

  defp expand_macro(mocked_alias, opts) do
    quote do: alias(unquote(mocked_alias), unquote(opts))
  end
end
