class Request < ApplicationRecord
  belongs_to :user, optional: true
end
