defmodule Geminiex.EntriesController do
  use Geminiex.Web, :controller

  alias Geminiex.{ImageProcessor}

  def crop(conn, params) do
    case convert_and_validate_params(params) do
      {:error} ->
        conn
          |> send_resp(400, "Bad request")
          |> halt()
      cleaned_params ->
        case cleaned_params["src"] do
          nil ->
            conn
              |> send_resp(404, "Cant find image source.")
              |> halt()

          image_src ->
            processed_image = ImageProcessor.process_image(image_src, cleaned_params)
            mime_type = MIME.type(processed_image.format)
            {:ok , image_data} = File.read(processed_image.path)
            ImageProcessor.delete_temp_image(processed_image.path)
            conn
              |> put_resp_header("content-disposition", "inline")
              |> put_resp_content_type(mime_type || "image/generic")
              |> send_resp(200, image_data)

        end
      end
  end

  defp convert_and_validate_params(params) do
    if (params["src"] || params["token"]) && (params["width"] && params["height"]) do
      width = min(String.to_integer(params["width"]), 4000)
      height = min(String.to_integer(params["height"]), 4000)
      quality = if params["quality"], do: String.to_integer(params["quality"])
      #grow = params["grow"] || false)
      params
        |> Map.merge(%{
          "width" => width,
          "height" => height,
          "quality" => quality})
    else
      {:error}
    end
  end
end
