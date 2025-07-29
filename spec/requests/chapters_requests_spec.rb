require 'rails_helper'

RSpec.describe "Chapters", type: :request do
  let!(:user) { create(:user, email: "prajwal@gmail.com", password: 'prajwal@1234') }
  let!(:subject_record) { create(:subject, user: user) }
  let!(:chapter_record) { create(:chapter, subject: subject_record) }

  context 'when user has logged in' do
    before do
      user_params = { user: { email: user.email, password: user.password } }
      post '/login', params: user_params
      @auth_token = response.cookies['jwt']
    end

    describe "GET /subjects/:subject_id/chapters" do
      it "returns a successful response" do
        get "/subjects/#{subject_record.id}/chapters", headers: { 'Cookie' => "jwt=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
      end
      
      it "filters chapters by search parameter" do
        create(:chapter, name: "advance topics", subject: subject_record)
        create(:chapter, name: "simple toipcs", subject: subject_record)
        
        get "/subjects/#{subject_record.id}/chapters", params: { search: "advance" }, headers: { 'Cookie' => "jwt=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("advance topics")
        expect(response.body).not_to include("simple toipcs")
      end

      context "When user is not logged in" do
        before { cookies.delete('jwt') }
        it "redirects to the login path" do
          get "/subjects/#{subject_record.id}/chapters"
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
          expect(flash[:notice]).to eq("You need to login first")
        end
      end
      
      context "When subject does not exist" do
        it "redirects to subjects path" do
          non_existent_id = subject_record.id + 10000000000
          get "/subjects/#{non_existent_id}/chapters", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subjects_path)
          expect(flash[:notice]).to eq("Subject not found!!")
        end
      end
    end

    describe "POST /subjects/:subject_id/chapters" do
      let(:valid_attributes) { { chapter: { name: "Introduction" } } }
      let(:invalid_attributes) { { chapter: { name: "" } } }

      it "creates a new chapter with valid attributes" do
        expect {
          post "/subjects/#{subject_record.id}/chapters", params: valid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
        }.to change(Chapter, :count).by(1)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(subject_chapters_path(subject_record))
        expect(flash[:notice]).to eq("Chapter created successfully!!")
      end

      it "does not create a new chapter with invalid attributes" do
        expect {
          post "/subjects/#{subject_record.id}/chapters", params: invalid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
        }.not_to change(Chapter, :count)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(subject_chapters_path)
      end
      
      context "when subject does not exist" do
        it "redirects to subjects path" do
          non_existent_id = subject_record.id + 10000000000
          post "/subjects/#{non_existent_id}/chapters", params: valid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subjects_path)
          expect(flash[:notice]).to eq("Subject not found!!")
        end
      end
    end
    
    describe "GET /subjects/:subject_id/chapters/" do
      it "redirects to chapters index " do
        get "/subjects/#{subject_record.id}/chapters/", headers: { 'Cookie' => "jwt=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
      end
      
      context "when chapter does not exist" do
        it "redirects to chapters index with notice" do
          non_existent_id = chapter_record.id + 10000000000
          get "/subjects/#{subject_record.id}/chapters/#{non_existent_id}/edit", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter not found!!")
        end
      end
    end

    describe "PUT /subjects/:subject_id/chapters/:id" do
      let(:updated_attributes) { { chapter: { name: "Advanced Topics" } } }
      let(:invalid_attributes) { { chapter: { name: "" } } }
      
      context "when chapter exists" do
        it "updates the chapter with valid attributes" do
          put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}", params: updated_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter updated successfully!!")
          expect(chapter_record.reload.name).to eq("Advanced Topics")
        end
        
        it "does not update the chapter with invalid attributes" do
          original_name = chapter_record.name
          put "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}", params: invalid_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path)
          expect(chapter_record.reload.name).to eq(original_name)
        end
      end

      context "when chapter does not exist" do
        it "redirects to chapters index with notice" do
          non_existent_id = chapter_record.id + 10000000000
          put "/subjects/#{subject_record.id}/chapters/#{non_existent_id}", params: updated_attributes, headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter not found!!")
        end
      end
    end

    describe "DELETE /subjects/:subject_id/chapters/:id" do
      let!(:chapter_to_delete) { create(:chapter, subject: subject_record) }

      context "when the chapter exists" do
        it "deletes the chapter" do
          expect {
            delete "/subjects/#{subject_record.id}/chapters/#{chapter_to_delete.id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          }.to change(Chapter, :count).by(-1)
          expect(response).to have_http_status(:ok)
          expect(flash[:notice]).to eq("Chapter deleted successfully!!")
        end
      end

      context "when chapter does not exist" do
        it "does not delete any chapter and redirects with notice" do
          non_existent_id = chapter_record.id + 10000000000
          expect {
            delete "/subjects/#{subject_record.id}/chapters/#{non_existent_id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          }.not_to change(Chapter, :count)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter not found!!")
        end
      end
    end

    describe "GET /subjects/:subject_id/chapters/:id" do
      context "when chapter exists" do
        it "redirects to paragraphs path" do
          get "/subjects/#{subject_record.id}/chapters/#{chapter_record.id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
        end
      end

      context "when chapter does not exist" do
        it "redirects to chapters index with notice" do
          non_existent_id = chapter_record.id + 10000000000
          get "/subjects/#{subject_record.id}/chapters/#{non_existent_id}", headers: { 'Cookie' => "jwt=#{@auth_token}" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(subject_chapters_path(subject_record))
          expect(flash[:notice]).to eq("Chapter not found!!")
        end
      end
    end
  end
end