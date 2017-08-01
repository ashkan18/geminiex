defmodule Geminiex.ImageProcessor do
  import Mogrify

  def process_image(image_src, params) do
    image_src
      |> read_remote_image()
      |> open()
      |> process_resize(params)
      |> process_formatting(params)
      |> verbose
      |> save(in_place: true)
  end

  def delete_temp_image(image_path) do
    spawn( fn ->
      File.rm(image_path)
    end)
  end

  defp read_remote_image(src) do
    remote_file = HTTPoison.get!(src)
    tempfile_path = tempfile_path(src)
    File.write(tempfile_path, remote_file.body)
    tempfile_path
  end

  defp tempfile_path(src) do
    file_name = :crypto.hash(:md5, src)
                  |> Base.encode16()
                  |> binary_part(16,16)
    "/tmp/" <> file_name
  end

  defp process_formatting(image, params) do
    if params["convert_to"], do: format(image, params["convert_to"]), else: image
  end

  defp process_resize(image, params) do
    case params["resize_to"] do
      type_to when type_to in ["fit", "fill", "limit"] ->
        image
          |> resize("#{params["width"]}x#{params["height"]}")
      "width" ->
        image
          |> resize(params["width"])
      "height" ->
        image
          |> resize("x#{params["height"]}")
      _ ->
        image
    end
  end
end