class VibeCard < ApplicationRecord
  has_many :nomikai_vibe_cards, dependent: :destroy

  validates :title, :description, presence: true
  validates :min_budget, :max_budget, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_group_size, :max_group_size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :max_budget, numericality: { greater_than_or_equal_to: :min_budget },
                         if: -> { min_budget.present? && max_budget.present? }
  validates :max_group_size, numericality: { greater_than_or_equal_to: :min_group_size },
                             if: -> { min_group_size.present? && max_group_size.present? }
  validates :active, inclusion: { in: [true, false] }
end
