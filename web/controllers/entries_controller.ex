defmodule Geminiex.EntriesController do
  use Geminiex.Web, :controller

  alias Geminiex.{ImageProcessor, FallbackController}

  action_fallback FallbackController

  def crop(conn, params) do
    with {:ok, cleaned_params} <- convert_and_validate_params(params) do
      processed_image = ImageProcessor.process_image(cleaned_params["src"], cleaned_params)
      mime_type = MIME.type(processed_image.format)
      {:ok , image_data} = File.read(processed_image.path)
      ImageProcessor.delete_temp_image(processed_image.path)
      conn
        |> put_resp_header("content-disposition", "inline")
        |> put_resp_content_type(mime_type || "image/generic")
        |> send_resp(200, image_data)
    end
  end

  defp convert_and_validate_params(params) do
    if (params["src"]) && (params["width"] && params["height"]) do
      width = min(String.to_integer(params["width"]), 4000)
      height = min(String.to_integer(params["height"]), 4000)
      quality = if params["quality"], do: String.to_integer(params["quality"])
      #grow = params["grow"] || false)
      new_param = params
                    |> Map.merge(%{
                      "width" => width,
                      "height" => height,
                      "quality" => quality})
      {:ok, params}
    else
      {:error, :invalid_request}
    end
  end
end
