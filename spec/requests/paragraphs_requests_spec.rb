require 'rails_helper'

RSpec.describe "Paragraphs", type: :request do
  let!(:user) { create(:user, email: "prajwal@gmail.com", password: 'prajwal@1234') }
  let!(:subject_record) { create(:subject, user: user) }
  let!(:chapter_record) { create(:chapter, subject: subject_record) }
  let!(:paragraph_record) { create(:paragraph, chapter: chapter_record, user: user) }

  context 'when user has logged in' do
    before do
      user_params = { user: { email: user.email, password: user.password } }
      post '/login', params: user_params
      @auth_token = response.cookies['jwt']
    end

    describe "GET /subjects/:subject_id/chapters/:chapter_id/paragraphs" do
      it "returns a successful response" do
        get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs", headers: { 'Cookie' => "jwt=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
      end
      
      it "filters paragraphs by search parameter" do
        create(:paragraph, title: "advanced topics", chapter: chapter_record, user: user)
        create(:paragraph, title: "simple topics", chapter: chapter_record, user: user)
        
        get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs", params: { search: "advanced" }, headers: { 'Cookie' => "jwt=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("advanced topics")
        expect(response.body).not_to include("simple topics")
      end

      context "when user is not logged in" do
        before { cookies.delete('jwt') }
        it "redirects to the login path" do
          get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs"
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
        end
      end
      
      context "when subject does not exist" do
        it "redirects to subjects path" do
          non_existent_id = subject_record.id + 10000000000
          get "/subjects/#{non_existent_id}/chapters/#{chapter_record.id}/paragraphs", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subjects_path)
          expect(flash[:notice]).to eq("Subject not found!!")
        end
      end
      
      context "when chapter does not exist" do
        it "redirects to chapters path" do
          non_existent_id = chapter_record.id + 10000000000
          get "/subjects/#{subject_record.id}/chapters/#{non_existent_id}/paragraphs", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter not found!!")
        end
      end
    end

    describe "GET /subjects/:subject_id/chapters/:chapter_id/paragraphs/:id" do
      it "returns a successful response" do
        get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
      end
      
      context "when paragraph does not exist" do
        it "redirects to paragraphs index with notice" do
          non_existent_id = paragraph_record.id + 10000000000
          get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{non_existent_id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapter_paragraphs_path(subject_record, chapter_record))
          expect(flash[:notice]).to eq("Paragraph not found!!")
        end
      end
      
      context "when user is not logged in" do
        before { cookies.delete('jwt') }
        it "redirects to login path" do
          get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}"
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
        end
      end
    end

    describe "POST /subjects/:subject_id/chapters/:chapter_id/paragraphs" do
      let(:valid_attributes) { { paragraph: { title: "Introduction", content: "This is the content." } } }
      let(:invalid_attributes) { { paragraph: { title: "", content: "" } } }

      it "creates a new paragraph with valid attributes" do
        expect {
          post "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs", params: valid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
        }.to change(Paragraph, :count).by(1)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(subject_chapter_paragraphs_path(subject_record, chapter_record))
        expect(flash[:notice]).to eq("Paragraph created successfully!!")
      end

      it "does not create a new paragraph with invalid attributes" do
        expect {
          post "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs", params: invalid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
        }.not_to change(Paragraph, :count)
        expect(response).to have_http_status(:found)
      end
      
      context "when subject does not exist" do
        it "redirects to subjects path" do
          non_existent_id = subject_record.id + 10000000000
          post "/subjects/#{non_existent_id}/chapters/#{chapter_record.id}/paragraphs", params: valid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subjects_path)
          expect(flash[:notice]).to eq("Subject not found!!")
        end
      end
      
      context "when chapter does not exist" do
        it "redirects to chapters path" do
          non_existent_id = chapter_record.id + 10000000000
          post "/subjects/#{subject_record.id}/chapters/#{non_existent_id}/paragraphs", params: valid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter not found!!")
        end
      end
    end

    describe "PUT /subjects/:subject_id/chapters/:chapter_id/paragraphs/:id" do
      let(:updated_attributes) { { paragraph: { title: "Updated Title", content: "Updated content." } } }
      let(:invalid_attributes) { { paragraph: { title: "", content: "" } } }
      
      context "when paragraph exists" do
        it "updates the paragraph with valid attributes" do
          put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}", params: updated_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapter_paragraphs_path(subject_record, chapter_record))
          expect(flash[:notice]).to eq("Paragraph updated successfully.")
          expect(paragraph_record.reload.title).to eq("Updated Title")
          expect(paragraph_record.reload.content).to eq("Updated content.")
        end
        
        it "does not update the paragraph with invalid attributes" do
          original_title = paragraph_record.title
          original_content = paragraph_record.content
          put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}", params: invalid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(paragraph_record.reload.title).to eq(original_title)
          expect(paragraph_record.reload.content).to eq(original_content)
        end
      end

      context "when paragraph does not exist" do
        it "redirects to paragraphs index with notice" do
          non_existent_id = paragraph_record.id + 10000000000
          put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{non_existent_id}", params: updated_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapter_paragraphs_path(subject_record, chapter_record))
          expect(flash[:notice]).to eq("Paragraph not found!!")
        end
      end
      
      context "when user is not logged in" do
        before { cookies.delete('jwt') }
        it "redirects to login path" do
          put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}", params: updated_attributes
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
        end
      end
    end

    describe "DELETE /subjects/:subject_id/chapters/:chapter_id/paragraphs/:id" do
      let!(:paragraph_to_delete) { create(:paragraph, chapter: chapter_record, user: user) }

      context "when the paragraph exists" do
        it "deletes the paragraph" do
          expect {
            delete "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_to_delete.id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          }.to change(Paragraph, :count).by(-1)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapter_paragraphs_path(subject_record, chapter_record))
          expect(flash[:notice]).to eq("Paragraph deleted successfully!!")
        end
      end

      context "when paragraph does not exist" do
        it "does not delete any paragraph and redirects with notice" do
          non_existent_id = paragraph_record.id + 10000000000
          expect {
            delete "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{non_existent_id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          }.not_to change(Paragraph, :count)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapter_paragraphs_path(subject_record, chapter_record))
          expect(flash[:notice]).to eq("Paragraph not found!!")
        end
      end
      
      context "when paragraph deletion fails" do
        it "redirects with alert" do
          allow_any_instance_of(Paragraph).to receive(:destroy).and_return(false)
          expect {
            delete "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_to_delete.id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          }.not_to change(Paragraph, :count)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapter_paragraph_path(subject_record, chapter_record, paragraph_to_delete))
          expect(flash[:alert]).to eq("Failed to delete paragraph.")
        end
      end
      
      context "when user is not logged in" do
        before { cookies.delete('jwt') }
        it "redirects to login path" do
          delete "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_to_delete.id}"
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
          expect(Paragraph.exists?(paragraph_to_delete.id)).to be true
        end
      end
    end
    
    describe "edge cases for set_paragraph" do
      context "when current_user is nil" do
        it "redirects to login path" do
          allow_any_instance_of(ParagraphsController).to receive(:current_user).and_return(nil)
          get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
        end
      end
    end
  end
  
  context 'when user is not logged in' do
    describe "all routes" do
      it "GET /index redirects to login path" do
        get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs"
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(login_path)
      end
      
      it "POST /create redirects to login path" do
        post "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs", params: { paragraph: { title: "Test", content: "Test" } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(login_path)
      end
      

      
      it "PUT /update redirects to login path" do
        put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}", params: { paragraph: { title: "Test", content: "Test" } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(login_path)
      end
      
      it "DELETE /destroy redirects to login path" do
        delete "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}/paragraphs/#{paragraph_record.id}"
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(login_path)
      end
    end
  end
end