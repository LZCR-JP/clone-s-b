class Participant < ApplicationRecord
  belongs_to :nomikai
  has_many :swipes
end
