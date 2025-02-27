RSpec.describe Comment do
  subject(:comment) { comments(:top_level) }

  describe 'validations' do
    describe '#same_parent_path' do
      context 'when the comment has a parent' do
        before { expect(comment.parent).to be_present }

        let(:comment) { comments(:reply) }

        context "when the parent comment's path is different" do
          before { comment.path = "/blog/some-other-article-#{SecureRandom.uuid}" }

          it 'is invalid' do
            expect(comment).not_to be_valid
            expect(comment.errors.to_hash).to eq({
              path: ['must match parent path'],
            })
          end
        end
      end
    end
  end
end
