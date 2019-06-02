defmodule MockAliasTest do
  use ExUnit.Case

  test "alias in one line" do
    assert MockOneLineAlias.get_foo() == Extras.Mocking.Foo
    assert MockOneLineAlias.get_bar() == Extras.Mocking.Bar
  end

  test "alias in one line including :as opions" do
    assert MockAliasWithAs.get_foo() == Extras.Mocking.Foo
  end

  test "alias multiple modules in one line" do
    assert MockMultiplesAliases.get_foo() == Extras.Mocking.Foo
    assert MockMultiplesAliases.get_bar() == Extras.Mocking.Bar
  end
end
