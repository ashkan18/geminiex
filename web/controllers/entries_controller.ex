defmodule Geminiex.EntriesController do
  use Geminiex.Web, :controller

  alias Geminiex.{ImageProcessor, FallbackController}

  action_fallback FallbackController

  def crop(conn, params) do
    with {:ok, cleaned_params} <- validate_and_convert(params) do
      image = ImageProcessor.process_image(cleaned_params["src"], cleaned_params)
      {:ok , image_data} = File.read(image.path)
      ImageProcessor.delete_temp_image(image.path)
      conn
        |> put_resp_header("content-disposition", "inline")
        |> put_resp_content_type(mime_type(image))
        |> send_resp(200, image_data)
    end
  end

  defp validate_and_convert(params) do
    with {:ok, validated_params} <- validate_resize_params(params) do
      cleaned_params = validated_params
        |> set_max("height")
        |> set_max("width")
        |> force_int("quality")
      {:ok, cleaned_params}
    end
  end

  defp validate_resize_params(params) do
    with {:ok, resize_to} <- Map.fetch(params, "resize_to"), {:ok, _src} <- Map.fetch(params, "src") do
      case resize_to do
        attr when attr in ["fit", "fill", "limit"] ->
          unless params["width"] && params["height"], do: {:error, :invalid_request}, else: {:ok, params}
        "width" ->
          unless params["width"], do: {:error, :invalid_request}, else: {:ok, params}
        "height" ->
          unless params["height"], do: {:error, :invalid_request}, else: {:ok, params}
        _ ->
          {:error, :invalid_request}
      end
    else
      :error ->
        {:error, :invalid_request}
    end
  end

  defp set_max(params, attr, max \\ 4000) do
    if params[attr], do: Map.merge(params, %{ attr => min(String.to_integer(params[attr]), max)}), else: params
  end
  defp force_int(params, attr) do
    if params[attr], do: Map.merge(params, %{ attr => String.to_integer(params[attr]) }), else: params
  end

  defp mime_type(image) do
    case image.format || String.replace(image.ext, ".", "") do
      format when format in ["", nil] -> "jpg" # default to jpg
      format -> format
    end
      |>MIME.type()
  end
end
