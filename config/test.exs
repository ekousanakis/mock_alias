# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :mock_alias,
  mock_alias: [
    {Extras.Example.Foo, Extras.Mocking.Foo},
    {Extras.Example.Bar, Extras.Mocking.Bar}
  ]
