require 'rails_helper'

RSpec.describe "layouts/application.html.haml", type: :view do
  context "when user is signed in" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:authenticated_root_path).and_return('/profile')
      allow(view).to receive(:destroy_user_session_path).and_return('/logout')
      render template: "layouts/application"
    end

    it "displays the navigation bar with Profile and Logout links" do
      pending("Outdated spec (view changed)")

      expect(rendered).to have_selector('nav.navbar')
      expect(rendered).to have_link('Profile', href: '/profile')
      expect(rendered).to have_link('Logout', href: '/logout')
    end
  end

  context "when user is not signed in" do
    before do
      allow(view).to receive(:user_signed_in?).and_return(false)
      allow(view).to receive(:new_user_session_path).and_return('/login')
      allow(view).to receive(:new_user_registration_path).and_return('/signup')
      render template: "layouts/application"

    end

    it "displays the navigation bar with Login and Sign Up links" do
      expect(rendered).to have_selector('nav.navbar')
      expect(rendered).to have_link('Login', href: '/login')
      expect(rendered).to have_link('Sign Up', href: '/signup')
    end
  end


end
