require 'rails_helper'

feature 'Event Pages' do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  before do
    create(:location)
  end

  scenario 'user visits a regular class event' do
    event = create(:event, location: Location.last, modifier: User.last, event_type: Event::EVENT_TYPE_CLASS)
    visit location_event_path(Location.last, event)
    expect(page).to have_selector('.show-event')
  end

  scenario 'user visits a tournament event' do
    event = create(:event, location: Location.last, modifier: User.last, event_type: Event::EVENT_TYPE_TOURNAMENT)
    visit location_event_path(Location.last, event)
    expect(page).to have_selector('.show-event')
  end

  scenario 'user visits a seminar event' do
    event = create(:event, location: Location.last, modifier: User.last, event_type: Event::EVENT_TYPE_SEMINAR)
    visit location_event_path(Location.last, event)
    expect(page).to have_selector('.show-event')
  end
end
