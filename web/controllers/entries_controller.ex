defmodule Geminiex.EntriesController do
  use Geminiex.Web, :controller

  alias Geminiex.{Repo, Entry, ImageProcessor}

  def crop(conn, params) do
    cleaned_params = convert_and_validate_resize_params(params)

    image_src = cleaned_params["src"] || entry_image_src(cleaned_params["token"])

    case image_src do
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

  defp convert_and_validate_resize_params(params) do

    with {:ok, width_param} <- Map.fetch(params, "width"),
          width = min(String.to_integer(width_param), 4000),
         {:ok, height_param} <- Map.fetch(params, "height"),
          height = min(String.to_integer(height_param), 4000),
         do: Map.merge(params, %{ "width" => width, "height" => height })
    # quality = if params["quality"], do: String.to_integer(params["quality"])
    # params
    #   |> Map.merge(%{
    #     "width" => min(String.to_integer(params["width"]), 4000),
    #     "height" => min(String.to_integer(params["height"]), 4000),
    #     "quality" => quality})
  end

  defp entry_image_src(token) do
    case Repo.get_by(Entry, token: token) do
      nil ->
        nil
      entry ->
        entry.source_url
    end
  end
end
