class AnyoneWithLink < Avo::Filters::BooleanFilter
  self.name = "Anyone With Link"

  def apply(request, query, values)
    query.anyone_with_link
  end

  def options
    [
      [true, "Anyone With Link"],
    ]
  end
end
