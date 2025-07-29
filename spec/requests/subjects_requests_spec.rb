require 'rails_helper'

RSpec.describe "Subjects", type: :request do
  let!(:user) { create(:user, email: "prajwal@gmail.com", password: 'prajwal@1234') }
  let!(:subject_record) { create(:subject, user: user) }

  context 'when user has logged in' do
    it "returns a successful response" do
      get "/subjects", headers: AuthenticationHelper.generate_cookie(user)
      
      expect(response).to have_http_status(:ok)
    end

    describe "GET /subjects" do
      context "When user is not logged in" do
        before {cookies.delete('jwt')}
        it "redirects to the login path" do
          post '/subjects'

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(login_path)
          expect(flash[:notice]).to eq("You need to login first")
        end
      end
    end

    describe "POST /subjects" do
      let(:valid_attributes) { { subject: { name: "Math" } } }
      let(:invalid_attributes) { { subject: { name: "" } } }      

      it "creates a new subject" do
        expect {
          post "/subjects", params: valid_attributes, headers: AuthenticationHelper.generate_cookie(user)
        }.to change(Subject, :count).by(1)
      end

      it "does not create a new subject with invalid attributes" do
        expect {
          post "/subjects", params: invalid_attributes, headers: AuthenticationHelper.generate_cookie(user)
        }.to change(Subject, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  describe "PUT /subjects/:id" do
      let(:updated_attributes) { { subject: { name: "Physics" } } }
    context "when subject exists" do
      it "updates an existing subject" do
        put "/subjects/#{subject_record.id}", params: updated_attributes, headers: AuthenticationHelper.generate_cookie(user)
        expect(response).to have_http_status(:found)
      end
    end
    

    context "when subject does not exists" do
      it "return not found error" do
        id_does_not_exists = subject_record.id + 10000000000

        put "/subjects/#{id_does_not_exists}", params: updated_attributes, headers: AuthenticationHelper.generate_cookie(user)
        expect(response).to have_http_status(:found)
      end
    end
  end

    describe "DELETE /subjects/:id" do
      # let!(:subject_record) { create(:subject, user: user) }

      context "when the subject exists" do
        it "deletes a subject" do
          expect {
            delete "/subjects/#{subject_record.id}", headers: AuthenticationHelper.generate_cookie(user)            
          }.to change(Subject, :count).by(-1)

          expect(response).to have_http_status(:ok)
        end
      end

      context "when subject does not exists" do
        it "returns a not found error" do
          id_does_not_exists = subject_record.id + 10000000000

          expect {
            delete "/subjects/#{id_does_not_exists}", headers: { 'Cookie' => "jwt=#{@auth_token}" }

        }.to change(Subject, :count).by(0)
        end
      end

      it "returns a successful response and assigns subjects" do
        get "/subjects", headers: AuthenticationHelper.generate_cookie(user)

        expect(response).to have_http_status(:ok)
      end

      it "filters subjects when search query  is present" do
        get "/subjects", params: {search: "Math"}, headers: AuthenticationHelper.generate_cookie(user)
        expect(response).to have_http_status(:ok)
      end

      describe "GET /subjects/:id" do
        context "When subject exists" do
          it "redirects to chapters path" do
            get "/subjects/#{subject_record.id}", headers: AuthenticationHelper.generate_cookie(user)

            expect(response).to have_http_status(:found)
          end
        end

        context "When subject does not exists" do
          it "404 not found" do
            id_does_not_exists = subject_record.id + -1
            post "/subjects/#{id_does_not_exists}", headers: AuthenticationHelper.generate_cookie(user)

            expect(response).to have_http_status(:not_found)
          end
        end
      end

    end
  end
end
