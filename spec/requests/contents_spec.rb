require 'rails_helper'

RSpec.describe ContentsController, type: :controller do
  let(:user) { create(:user) }
  let(:content) { create(:content) }

  before do
    sign_in user # Ensure user is signed in for actions that require authentication
  end

  describe 'GET #index' do
    it 'assigns all contents to @contents' do
      create_list(:content, 3)
      get :index
      expect(assigns(:contents).count).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested content to @content' do
      get :show, params: { id: content.id }
      expect(assigns(:content)).to eq(content)
    end
  end

  describe 'GET #new' do
    it 'assigns a new content to @content' do
      get :new
      expect(assigns(:content)).to be_a_new(Content)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new content and redirects to the show page' do
        expect {
          post :create, params: { content: { story_text: 'Some story', image_url: 'http://example.com/image.jpg' } }
        }.to change(Content, :count).by(1)
        expect(response).to redirect_to(assigns(:content))
        expect(flash[:notice]).to eq('Content was successfully created.')
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates the content and redirects to the show page' do
        patch :update, params: { id: content.id, content: { story_text: 'Updated story', image_url: 'http://example.com/updated_image.jpg' } }
        content.reload
        expect(content.story_text).to eq('Updated story')
        expect(response).to redirect_to(content)
        expect(flash[:notice]).to eq('Content was successfully updated.')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the content and redirects to the index page' do
      content_to_delete = create(:content)
      expect {
        delete :destroy, params: { id: content_to_delete.id }
      }.to change(Content, :count).by(-1)
      expect(response).to redirect_to(contents_url)
      expect(flash[:notice]).to eq('Content was successfully destroyed.')
    end
  end
end
