class UserSerializer < ActiveModel::Serializer
  attributes :id, :content
  has_many :articles
  has_many :comments
end
