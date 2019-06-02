defmodule MockOneLineAlias do
  use MockPathAlias

  mock_alias Extras.Example.Foo
  mock_alias Extras.Example.Bar

  def get_foo do
    Foo.get_module_name()
  end

  def get_bar do
    Bar.get_module_name()
  end
end
