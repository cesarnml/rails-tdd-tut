require "rails_helper"

describe ArticlesController do
  describe 'index' do
    subject { get :index }
    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      create_list :article, 2
      subject
      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq(
          {
            'title' => article.title,
            'content' => article.content,
            'slug' => article.slug
          }
        )
      end
    end

    it 'should return articles in the proper order' do
      old_article = create :article
      new_article = create :article
      subject

      expect(json_data.first["id"]).to eq(new_article.id.to_s)
      expect(json_data.last["id"]).to eq(old_article.id.to_s)
    end

    it "should paginate results" do
      create_list :article, 3
      get :index, params: { page: 2, per_page: 1 }
      expect(json_data.length).to eq 1
      expected_article = Article.recent.second.id.to_s
      expect(json_data.first["id"]).to eq(expected_article)
    end
  end

  describe "#show" do
    let(:article) { create :article }
    subject { get :show, params: { id: article.id } }

    it "should return success response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "should return proper json" do
      subject
      expect(json_data['attributes']).to eq({
        "title" => article.title,
        "content" => article.content,
        "slug" => article.slug
      })
    end
  end

  describe "#create" do
    subject { post :create }

    context "when no code provided" do
      it_behaves_like "forbidden_requests"
    end

    context "when invalid code provided" do
      before { request.headers["authorization"] = "Invalid token" }
      it_behaves_like "forbidden_requests"
    end
    
    context "when authorized" do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }
      context "when invalid parameters provided" do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        subject { post :create, params:  invalid_attributes }
        it "should return 422 status code" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "should return proper error json" do
          subject
          expect(json["errors"]).to include(
            {
              "source" => { "pointer" => "/data/attributes/title"},
              "detail" => "can't be blank"
            },
            {
              "source" => { "pointer" => "/data/attributes/content"},
              "detail" => "can't be blank"
            },
            {
              "source" => { "pointer" => "/data/attributes/slug"},
              "detail" => "can't be blank"
            }
          )
        end
      end

      context "when valid request sent" do
        let(:valid_attributes) do
          {
            "data"=> {
              "attributes" => {
                "title" => "test title",
                "content" => "test content",
                "slug" => "test-title"
              }
            }
          }
        end

        subject { post :create, params: valid_attributes }

        it "should response with status code 201" do
          subject
          expect(response).to have_http_status(:created)
        end

        it "should have proper json body" do
          subject
          expect(json_data["attributes"]).to include(valid_attributes["data"]["attributes"])
        end

        it "should create the article" do
          expect{ subject }.to change{ Article.count }.by(1)
        end
      end
    end
  end

  describe "#update" do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }
    subject { patch :update, params: {id: article.id} }

    context "when no code provided" do
      it_behaves_like "forbidden_requests"
    end

    context "when invalid code provided" do
      before { request.headers["authorization"] = "Invalid token" }
      it_behaves_like "forbidden_requests"
    end

    context "when authorized" do
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }

      context "when trying to update not owned article" do
        let(:other_user) { create :user }
        let(:other_article) { create :article, user: other_user }
  
        subject { patch :update, params: {id: other_article.id } }
  
        it_behaves_like "forbidden_requests"
      end

      context "when invalid parameters provided" do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        subject { patch :update, params: invalid_attributes.merge(id: article.id) }
        it "should return 422 status code" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "should return proper error json" do
          subject
          expect(json["errors"]).to include(
            {
              "source" => { "pointer" => "/data/attributes/title"},
              "detail" => "can't be blank"
            },
            {
              "source" => { "pointer" => "/data/attributes/content"},
              "detail" => "can't be blank"
            }
          )
        end
      end
      context "when valid request sent" do
        let(:valid_attributes) do
          {
            "data" => {
              "attributes" => {
                "title" => "update title",
                "content" => "update content",
              }
            }
          }
        end

        subject { patch :update, params: valid_attributes.merge("id" => article.id) }

        it "should respond with status code 200" do
          subject
          expect(response).to have_http_status(:ok)
        end

        it "should have proper json body" do
          subject
          expect(json_data["attributes"]).to include(valid_attributes["data"]["attributes"])
        end

        it "should update the article title" do
          subject
          expect(article.reload.title).to eq(valid_attributes["data"]["attributes"]["title"])
        end

        it "should update the article content" do
          subject
          expect(article.reload.content).to eq(valid_attributes["data"]["attributes"]["content"])
        end
      end
    end
  end

  describe "#destroy" do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }

    subject { delete :destroy, params: { id: article.id } }

    context "when no code provided" do
      it_behaves_like "forbidden_requests"
    end

    context "when invalid code provided" do
      before { request.headers["authorization"] = "Invalid code" }
      it_behaves_like "forbidden_requests"
    end

    context "when authorized" do
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }
      context "when trying to delete not owned article" do
        let(:other_user) { create :user }
        let(:other_article) { create :article, user: other_user }

        subject { delete :destroy, params: { id: other_article.id } }

        it_behaves_like "forbidden_requests"
      end

      context "when valid request sent" do
        it "should respond with status code 204" do
          subject
          expect(response).to have_http_status(:no_content)
        end

        it "should have empty json body" do
          subject
          expect(response.body).to be_blank
        end

        it "should delete the article" do
          article
          expect{ subject }.to change{ user.articles.count }.by(-1)
        end
      end
    end
  end
end
