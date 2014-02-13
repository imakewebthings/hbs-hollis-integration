module TopicHelper
  def active_topic_class(topic, active)
    active && active.slug == topic.slug ? 'active' : nil
  end
end
