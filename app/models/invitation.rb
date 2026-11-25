class Invitation < ApplicationRecord
  STATUSES = ["pending", "accepted", "revoked"].freeze
  RESEND_COOLDOWN = 1.minute

  belongs_to :nomikai
  has_one :participant, dependent: :nullify

  has_secure_token :token

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: :nomikai_id }
  validates :status, inclusion: { in: STATUSES }

  scope :visible, -> { where.not(status: "revoked") }

  STATUSES.each do |value|
    define_method(:"#{value}?") { status == value }
  end

  def deliver!
    update!(sent_at: Time.current)
    InvitationMailer.with(invitation: self).invite.deliver_later
  end

  def accept!
    update!(status: "accepted", accepted_at: Time.current)
  end

  def revoke!
    update!(status: "revoked")
  end

  # Re-invite someone whose invite was revoked. A fresh token kills the old link.
  def reopen!
    regenerate_token
    update!(status: "pending", accepted_at: nil)
  end

  def recently_sent?
    sent_at.present? && sent_at > RESEND_COOLDOWN.ago
  end
end
