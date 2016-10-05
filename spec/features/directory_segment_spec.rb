require 'rails_helper'

feature "Directory Segments" do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits the directory index" do
    create(:directory_segment, name: 'United States')
    create(:team)
    visit directory_index_path
    expect(page).to have_text('United States')
  end

  scenario "user visits a known directory segment" do
    create(:directory_segment, name: 'United States')
    visit directory_segment_path(country: 'United States')
    expect(page).to have_text('United States')
  end

  scenario "user visits a synthetic directory segment" do
    visit directory_segment_path(country: 'Canada')
    expect(page).to have_text('Canada')
  end
end
