defmodule Geminiex.ImageProcessor do
  import Mogrify

  def process_image(image_src, params) do
    image_src
      |> read_remote_image()
      |> open()
      |> resize("#{params["width"]}x#{params["height"]}")
      |> save(in_place: true)
      |> verbose()
  end

  def delete_temp_image(image_path) do
    spawn( fn ->
      File.rm(image_path)
    end)
  end

  def read_remote_image(src) do
    remote_file = HTTPoison.get!(src)
    file_name = Ecto.UUID.generate
                  |> binary_part(16,16)
    file_path = "/tmp/" <> file_name
    File.write(file_path, remote_file.body)
    file_path
  end
end