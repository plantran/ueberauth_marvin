defmodule Ueberauth.Strategy.Marvin do
	@moduledoc """
	Provides an Ueberauth strategy for authenticating with 42's intranet.
	"""

	use Ueberauth.Strategy, uid_field: :uid,
                          default_scope: "",
                          oauth2_module: Ueberauth.Strategy.Marvin.OAuth

	alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

	@doc """
  Handles initial request for 42's intranet authentication.
  """

	def handle_request!(conn) do
		scopes = conn.params["scope"] || option(conn, :default_scope)
	end

	@doc """
  Handles the callback from 42'intranet.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    params = [code: code]
    opts = [redirect_uri: callback_url(conn)]
    case Ueberauth.Strategy.Marvin.OAuth.get_access_token(params, opts) do
      {:ok, token} ->
        fetch_user(conn, token)
      {:error, {error_code, error_description}} ->
        set_errors!(conn, [error(error_code, error_description)])
    end
  end

	@doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

	@doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:marvin_user, nil)
    |> put_private(:marvin_token, nil)
  end

	@doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.marvin_user[uid_field]
  end

	@doc """
  Includes the credentials from the 42's intranet response.
  """
  def credentials(conn) do
    token        = conn.private.marvin_token
    scope_string = (token.other_params["scope"] || "")
    scopes       = String.split(scope_string, ",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      token_type: Map.get(token, :token_type),
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

	@doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.marvin_user
		user
    # %Info{
    #   email: user["email"],
    #   first_name: user["given_name"],
    #   image: user["picture"],
    #   last_name: user["family_name"],
    #   name: user["name"],
    #   urls: %{
    #     profile: user["profile"],
    #     website: user["hd"]
    #   }
    # }
  end

	@doc """
  Stores the raw information (including the token) obtained from the google callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.marvin_token,
        user: conn.private.marvin_user
      }
    }
  end

end
