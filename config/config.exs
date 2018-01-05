use Mix.Config

config :logger, level: :debug

config :docker, cert_path: System.get_env("DOCKER_CERT_PATH")
config :docker, host: System.get_env("DOCKER_HOST")
config :docker, version: "v1.32"
