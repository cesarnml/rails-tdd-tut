class CommentsController < ApplicationController
  skip_before_action :authorize!, only: %i[index]
  before_action :load_article
  # GET /comments
  def index
    comments = article.comments.page(params[:page]).per(params[:per_page])
    render json: comments
  end

  # POST /comments
  def create
    comment = article.comments.build(comment_params.merge(user: current_user))

    comment.save!
    render json: comment, status: :created, location: article
  rescue StandardError
    render json: comment,
           adapter: :json_api,
           serializer: ErrorSerializer,
           status: :unprocessable_entity
  end

  private

  # Only allow a trusted parameter "white list" through.
  attr_reader :article
  def load_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:data).require(:attributes).permit(:content) ||
      ActionController::Parameters.new
  end
end
