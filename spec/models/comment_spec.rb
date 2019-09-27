require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#validations' do
    it 'should have a valid factory' do
      comment = build :comment
      expect(comment).to be_valid
    end

    it 'should validate the presence of attributes' do
      comment = Comment.new
      expect(comment).not_to be_valid
      expect(comment.errors.messages).to include(
        {
          content: ["can't be blank"],
          user: ['must exist'],
          article: ['must exist']
        }
      )
    end
  end
end
