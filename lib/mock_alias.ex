defmodule MockPathAlias do
  @app Mix.Project.config()[:app]

  defmacro __using__(_) do
    quote do
      import MockPathAlias
    end
  end

  defmacro mock_alias(mock_alias, opts \\ [])

  # alias Foo.Bar.Buzz, as: BuzzBarFoo
  # alias Foo.Bar.Buzz
  defmacro mock_alias({:__aliases__, _, _} = ast_mock_alias, opts) do
    new_mocked_alias =
      if Mix.env() === :test do
        mock_alias = Macro.expand(ast_mock_alias, __CALLER__)

        @app
        |> Application.get_env(:mock_alias)
        |> Enum.find({nil, nil}, &(elem(&1, 0) == mock_alias))
        |> elem(1)
        |> validate(mock_alias)
      else
        ast_mock_alias
      end

    expand_macro(new_mocked_alias, opts)
  end

  # alias Foo.Bar.{Baz, Buzz}
  defmacro mock_alias({{:., _, [{_, _, root_path}, :{}]}, _, aliases} = ast_mock_aliases, _opts) do
    new_mocked_aliases =
      if Mix.env() == :test do
        mock_alias_list = @app |> Application.get_env(:mock_alias)

        Enum.map(aliases, fn {_, _, each_alias} ->
          mock_alias = Module.concat(root_path ++ each_alias)

          mock_alias_list
          |> Enum.find({nil, nil}, &(elem(&1, 0) === mock_alias))
          |> elem(1)
          |> validate(mock_alias)
        end)
      else
        [ast_mock_aliases]
      end

    Enum.map(new_mocked_aliases, &expand_macro(&1))
  end

  defp validate(new_mocked_alias, target_mock_alias) do
    cond do
      new_mocked_alias === nil ->
        raise "declare mocked alias for the #{inspect(target_mock_alias)}"

      target_mock_alias.__info__(:functions) !== new_mocked_alias.__info__(:functions) ->
        raise "declare mocking function(s) for the #{inspect(new_mocked_alias)} module"

      true ->
        new_mocked_alias
    end
  end

  defp expand_macro(mocked_alias) do
    quote do: alias(unquote(mocked_alias))
  end

  defp expand_macro(mocked_alias, opts) do
    quote do: alias(unquote(mocked_alias), unquote(opts))
  end
end
