class AccessToken < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  belongs_to :user
  after_initialize :generate_token

  private

  def generate_token
    loop do
      # break if token.present? && AccessToken.exists?(token: token)
      break if token.present?
      self.token = SecureRandom.hex(10)
    end
  end
end
