module ContributorHelper
  include ActiveSupport::Inflector

  def active_author_class(author, active)
    active && active.name_slug == author.name_slug ? 'active' : ''
  end

  def author_query(author)
    "#{transliterate(author.surname)}, #{transliterate(author.given_name)}"
  end

  def author_ribbon(author)
    "#{author.given_name} #{author.surname}"
  end

  def active_unit_class(unit, active)
    active && active.primary_unit_slug == unit.primary_unit_slug ? 'active' : ''
  end

  def coauthor_query(author)
    if author.coauthors.present?
      "#{author_query(author)}|#{unit_query(author.coauthors)}"
    end
  end

  def unit_query(authors)
    authors.to_a.map{|author| author_query(author) }.join('|')
  end
end
