defmodule Geminiex.EntriesControllerTest do
  use Geminiex.ConnCase

  describe "crop/2" do
    test "returns Bad request when missing token or src" do
      result = build_conn()
          |> get("/crop")
          |> response(400)
      assert result == "Bad request"
    end

    test "returns Bad request when missing width and height" do
      result = build_conn()
          |> get("/crop", [src: "test"])
          |> response(400)
      assert result == "Bad request"
    end

    test "returns image when processing the image with default jpeg as content-type" do
      result = build_conn()
          |> get("/crop", [src: "https://avatars1.githubusercontent.com/u/1230819", resize_to: "fill", height: "20", width: "20"])
      assert response(result, 200) != nil
      assert Plug.Conn.get_resp_header(result, "content-type") == ["image/jpeg; charset=utf-8"]
    end

    test "returns image when processing the image and change format to png" do
      result = build_conn()
          |> get("/crop", [src: "https://avatars1.githubusercontent.com/u/1230819", resize_to: "fill", height: "20", width: "20", convert_to: "jpg"])
      assert response(result, 200) != nil
      assert Plug.Conn.get_resp_header(result, "content-type") == ["image/jpeg; charset=utf-8"]
    end
  end
end