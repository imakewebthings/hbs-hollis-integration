module ContributorHelper
  def active_author_class(author, active)
    active && active.name_slug == author.name_slug ? 'active' : nil
  end

  def format_author_for_lc(author)
    parts = author.name.split
    last = parts.pop
    "#{last}, #{parts.join(' ')}"
  end
end
