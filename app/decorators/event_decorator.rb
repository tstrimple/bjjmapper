class EventDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  
  delegate_all
  decorates_finders
  decorates_association :location
  decorates_association :instructor
  decorates_association :organization

  def duration
    s = object.starting.try(:strftime, '%l:%M%p').try(:strip)
    e = object.ending.try(:strftime, '%l:%M%p').try(:strip)
    "#{s}-#{e}"
  end

  def event_type_name
    return h.event_type_name(object.event_type)
  end
  
  def image
    organization.try(:image) || instructor.try(:image) || location.try(:image)
  end

  def image_large
    organization.try(:image_large) || instructor.try(:image_large) || location.try(:image_large)
  end
  
  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i, class: 'text-muted') { DEFAULT_DESCRIPTION }
    end
  end

  def color_ordinal
    location.instructor_color_ordinal(instructor)
  end
end
