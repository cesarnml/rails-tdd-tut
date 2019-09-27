class Article < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }

  belongs_to :user
  has_many :comments, dependent: :destroy
end
