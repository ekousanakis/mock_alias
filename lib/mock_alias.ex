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
  defmacro mock_alias({:__aliases__, _, _} = mock_alias, opts) do
    new_mocked_alias =
      if Mix.env() === :test do
        @app
        |> Application.get_env(:mock_alias)
        |> Enum.find({nil, nil}, &(elem(&1, 0) == Macro.expand(mock_alias, __CALLER__)))
        |> elem(1)
        |> case do
          nil ->
            raise "declare mocked alias for the #{inspect(Macro.expand(mock_alias, __CALLER__))}"

          new_mocked_alias ->
            new_mocked_alias
        end
      else
        mock_alias
      end

      expand_macro(new_mocked_alias, opts)
  end

  # alias Foo.Bar.{Baz, Buzz}
  defmacro mock_alias({{:., _, [{_, _, root_path}, :{}]}, _, aliases} = mock_alias, _opts) do
    new_mocked_aliases =
      if Mix.env() == :test do
        mock_alias_list = @app |> Application.get_env(:mock_alias)

        Enum.map(aliases, fn {_, _, each_alias} ->
          full_alias = Module.concat(root_path ++ each_alias)

          mock_alias_list
          |> Enum.find({nil, nil}, &(elem(&1, 0) === full_alias))
          |> elem(1)
          |> case do
            nil ->
              raise "declare mocked alias for the #{inspect(full_alias)}"

            new_mocked_alias ->
              new_mocked_alias
          end
        end)
      else
        [mock_alias]
      end

    Enum.map(new_mocked_aliases, &expand_macro(&1))
  end

  def expand_macro(mocked_alias) do
    quote do: alias unquote(mocked_alias)
  end

  def expand_macro(mocked_alias, opts) do
    quote do: alias(unquote(mocked_alias), unquote(opts))
  end
end
