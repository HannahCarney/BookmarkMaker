require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "User signs in" do

  before(:each) do
    User.create(:email => "test@test.com",
                :password => 'test',
                :password_confirmation => 'test')
  end

  scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end

end

feature 'User signs out' do

  before(:each) do
    User.create(:email => "test@test.com",
                :password => 'test',
                :password_confirmation => 'test')
  end

  scenario 'while being signed in' do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Goodbye!") # where does this message go?
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end

  feature "User forgets password" do

    before(:each) do
    user = User.create(:email => "test@test.com",
                      :password => 'test',
                      :password_confirmation => 'test')
      allow_any_instance_of(User).to receive(:send_email)
    end

  scenario 'User requests password reset' do
    visit '/'
    expect{request_token("test@test.com")}.to change{User.first(:email => "test@test.com").password_token}
  end

  scenario 'User can change password' do
    visit '/'
    request_token("test@test.com")
    visit "/users/reset_password/#{User.first(:email => "test@test.com").password_token}"
    expect{change_password("new_password") }.to change{User.first(:email => "test@test.com").password_digest}
  end
end