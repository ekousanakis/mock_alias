defmodule MockAliasWithAs do
  use MockPathAlias

  mock_alias(Extras.Example.Foo, as: FROUFOU)

  def get_foo do
    FROUFOU.get_module_name()
  end
end
