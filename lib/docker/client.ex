defmodule Docker.Client do
  require Logger

  defp base_url do
    host = Application.get_env(:docker, :host) || System.get_env("DOCKER_HOST")
    version = Application.get_env(:docker, :version)
    "#{host}/#{version}"
    |> String.replace("tcp://", "https://")
    |> String.rstrip(?/)
  end

  defp options do
    cert_path = Application.get_env(:docker, :cert_path) || System.get_env("DOCKER_CERT_PATH")
    [
      ssl: [
        certfile: cert_path <> "/cert.pem",
        keyfile: cert_path <> "/key.pem",
        cacertfile: cert_path <> "/ca.pem",
      ]
    ]
  end

  @default_headers %{"Content-Type" => "application/json"}

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(resource, headers \\ @default_headers) do
    Logger.debug "Sending GET request to the Docker HTTP API: #{resource}"
    base_url() <> resource
    |> HTTPoison.get!(headers, options())
    |> decode_body
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(resource, data \\ "", headers \\ @default_headers) do
    Logger.debug "Sending POST request to the Docker HTTP API: #{resource}, #{inspect data}"
    data = Poison.encode! data

    base_url() <> resource
    |> HTTPoison.post!(data, headers, options())
    |> decode_body
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(resource, headers \\ @default_headers) do
    Logger.debug "Sending DELETE request to the Docker HTTP API: #{resource}"
    base_url() <> resource
    |> HTTPoison.delete!(headers, options())
  end

  defp decode_body(%HTTPoison.Response{body: ""}) do
    Logger.debug "Empty response"
    :nil
  end
  defp decode_body(%HTTPoison.Response{body: body}) do
    Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} -> dict
      {:error, _} -> body
    end
  end
end
