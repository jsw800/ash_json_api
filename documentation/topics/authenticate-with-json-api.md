# Authenticating with AshJsonApi

Authenticating with AshJsonApi requires a few things. The first thing to note is that this is not something that is provided for you out of the box by `ash_authentication`.

You will need to

- connect the authentication action to a route manually
- need to extract the resulting authentication token
- set it as a header or as metadata to provide it to the client to use on future requests

## The route

In this example, we will use the standard `:sign_in_with_password` action that is created by `ash_authentication` under the hood, and we will return the token as top-level request metadata

```elixir
# in your user resource
routes do
  # read actions that return *only one resource* are allowed to be used with
  # `post` routes.

  post :sign_in_with_password do
    route "/sign_in/:id"

    # given a successful request, we will modify the route to include the
    # generated token
    metadata(fn _subject, user, _request ->
      %{token: user.__metadata__.token}
    end)
  end
end
```
