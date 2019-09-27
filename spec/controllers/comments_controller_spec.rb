require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create :user}
  let(:article) { create :article, user: user }

  describe "GET #index" do
    let(:comment) { create :comment, article: article, user: user }
    let(:other_comment) { create :comment }

    subject { get :index, params: { article_id: article.id, page: 1, per_page: 2 } }
    it "returns a success response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "should return only comments belonging to article" do
      comment
      other_comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first["relationships"]["article"]["data"]["id"]).to eq(comment.article.id.to_s)
      expect(json_data.first["id"]).to eq(comment.id.to_s)
    end

    it "should return paginated results" do
      comments = create_list :comment, 3, article: article
      subject
      expect(json_data.length).to eq(2)
      expected_comment = comments.first.id.to_s
      expect(json_data.first["id"]).to eq(expected_comment)
    end

    it "should have proper json body" do
      comment
      subject
      expect(json_data.first["attributes"]).to eq({
        "content" => comment.content
      })
    end

    it "should have related objects information in the response" do
      comment
      subject
      relationships = json_data.first["relationships"]
      expect(relationships["article"]["data"]["id"]).to eq(article.id.to_s)
      expect(relationships["user"]["data"]["id"]).to eq(user.id.to_s)

    end
  end

  describe "POST #create" do  
    context "when not authorized" do
      subject { post :create, params: { article_id: article.id } }

      it_behaves_like "forbidden_requests"
    end
    
    context "when authorized" do
      let(:access_token) { user.create_access_token }
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }

      context "with valid params" do
        subject { post :create, params: {article_id: article.id, comment: valid_attributes } }
        let(:valid_attributes) { {content: "My awesome article"} }
        it "creates a new Comment" do
          expect { subject }.to change(article.comments, :count).by(1)
        end
  
        it "should have 201 code" do
          subject
          expect(response).to have_http_status(:created)
        end

        it "renders a JSON response with the new comment" do
          subject
          expect(json_data["attributes"]).to eq({
            "content" => "My awesome article"
          })
        end
      end
  
      context "with invalid params" do
        let(:invalid_attributes) { { content: ''} }
        it "renders a JSON response with errors for the new comment" do
          post :create, params: {article_id: article.id, comment: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end
end
