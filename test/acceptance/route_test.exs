defmodule Test.Acceptance.RouteTest do
  use ExUnit.Case, async: true

  defmodule Actions do
    use Ash.Resource,
      domain: Test.Acceptance.RouteTest.Domain,
      extensions: [AshJsonApi.Resource]

    json_api do
      routes do
        route(:get, "/say_hello/:to", :say_hello)
        route(:get, "/say_hello", :say_hello, query_params: [:to])
        route(:post, "/required_say_hello/:to", :with_required)
        route(:post, "/trigger_job", :trigger_job)
      end
    end

    actions do
      action :say_hello, :string do
        argument(:to, :string, allow_nil?: false)

        run(fn input, _ ->
          {:ok, "Hello, #{input.arguments.to}!"}
        end)
      end

      action :with_required, :string do
        argument(:to, :string, allow_nil?: false)
        argument(:from, :string, allow_nil?: false)

        run(fn input, _ ->
          {:ok, "Hello, #{input.arguments.to}, from: #{input.arguments.from}!"}
        end)
      end

      action :trigger_job do
        run(fn _input, _ ->
          :ok
        end)
      end
    end
  end

  defmodule Domain do
    use Ash.Domain,
      extensions: [
        AshJsonApi.Domain
      ]

    json_api do
      router(Test.Acceptance.RouteTest.Router)
      log_errors?(false)
    end

    resources do
      resource(Actions)
    end
  end

  defmodule Router do
    use AshJsonApi.Router, domain: Domain
  end

  import AshJsonApi.Test

  test "generic actions can be called" do
    assert Domain
           |> get("/say_hello/fred", status: 200)
           |> Map.get(:resp_body)
           |> Kernel.==("Hello, fred!")
  end

  test "generic actions can be called with query params" do
    assert Domain
           |> get("/say_hello?to=fred", status: 200)
           |> Map.get(:resp_body)
           |> Kernel.==("Hello, fred!")
  end

  test "generic actions with no return can be called" do
    assert Domain
           |> post("/trigger_job", %{}, status: 201)
           |> Map.get(:resp_body)
           |> Kernel.==(%{"success" => true})
  end

  test "generic actions with required inputs" do
    assert Domain
           |> post(
             "/required_say_hello/fred",
             %{
               data: %{
                 from: "joe"
               }
             },
             status: 201
           )
           |> Map.get(:resp_body)
  end
end
