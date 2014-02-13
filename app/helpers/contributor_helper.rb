module ContributorHelper
  def active_author_class(author, active)
    active && active.name_slug == author.name_slug ? 'active' : nil
  end
end
