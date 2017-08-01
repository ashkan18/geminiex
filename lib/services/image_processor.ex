defmodule Geminiex.ImageProcessor do
  import Mogrify

  def process_image(image_src, params) do
    tempfile_path = tempfile_path(image_src)
    image_src
      |> read_remote_image(tempfile_path)
      |> open()
      |> process_resize(params)
      |> process_formatting(params)
      |> verbose
      |> save(path: String.replace(tempfile_path, "_orig", "_res"))
  end

  def delete_temp_image(image_path) do
    spawn( fn ->
      File.rm(image_path)
      File.rm(String.replace(image_path, "_res", "_orig"))
    end)
  end

  defp read_remote_image(src, tempfile_path) do
    remote_file = HTTPoison.get!(src)
    File.write(tempfile_path, remote_file.body)
    tempfile_path
  end

  defp tempfile_path(src) do
    file_name = :crypto.hash(:md5, src)
                  |> Base.encode16()
                  |> binary_part(16,16)
    "/tmp/" <> file_name <> "_orig"
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