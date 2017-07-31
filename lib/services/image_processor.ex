defmodule Geminiex.ImageProcessor do
  import Mogrify

  def process_image(image_src, params) do
    image_src
      |> read_remote_image()
      |> open()
      |> resize("#{params["width"]}x#{params["height"]}")
      |> process_formatting(params)
      |> save()
      |> verbose()
  end

  def delete_temp_image(image_path) do
    spawn( fn ->
      File.rm(image_path)
    end)
  end

  defp read_remote_image(src) do
    remote_file = HTTPoison.get!(src)
    file_name = :crypto.hash(:md5, src)
                  |> Base.encode16()
                  |> binary_part(16,16)
    file_path = "/tmp/" <> file_name
    File.write(file_path, remote_file.body)
    file_path
  end

  defp process_formatting(image, params) do
    if params["convert_to"], do: format(image, params["convert_to"]), else: image
  end
end