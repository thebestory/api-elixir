defmodule TheBestory.API.View.Error do
  use TheBestory.API, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `TheBestory.API.Helpers.Error.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &Helpers.Error.translate_error/1)
  end

  def render("404.json", _assigns), do: %{
    errors: %{detail: "Page not found"}
  }

  def render("500.json", _assigns), do: %{
    errors: %{detail: "Internal server error"}
  }

  def render("error.json", %{message: message}), do: %{
    errors: %{message: message}
  }

  # When encoded, the changeset returns its errors
  # as a JSON object. So we just pass it forward.
  def render("error.json", %{changeset: changeset}), do: %{
    errors: translate_errors(changeset)
  }

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns),
    do: render "500.json", assigns
end
