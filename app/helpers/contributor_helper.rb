module ContributorHelper
  def active_author_class(author, active)
    active && active.name_slug == author.name_slug ? 'active' : ''
  end

  def active_unit_class(unit, active)
    active && active.primary_unit_slug == unit.primary_unit_slug ? 'active' : ''
  end

  def unit_query(authors)
    authors.to_a.map{|a| "#{a.surname}, #{a.given_name}" }.join('|')
  end
end
