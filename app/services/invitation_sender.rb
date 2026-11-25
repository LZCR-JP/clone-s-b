# Turns a free-form list of emails into invitations for a nomikai, sorting
# each address into a bucket so the host gets a clear summary.
class InvitationSender
  MAX_PER_REQUEST = 20

  Result = Struct.new(:sent, :already_invited, :already_joined, :invalid, :skipped_self, :truncated,
                      keyword_init: true) do
    def empty?
      [sent, already_invited, already_joined, invalid, skipped_self].all?(&:empty?)
    end

    def notice
      return if sent.empty?

      "Invite#{'s' if sent.size > 1} sent to #{sent.to_sentence}."
    end

    def alert
      return "Enter at least one email address." if empty?

      messages = []
      messages << "Already invited: #{already_invited.to_sentence}." if already_invited.any?
      messages << "Already joined: #{already_joined.to_sentence}." if already_joined.any?
      messages << "Not a valid email: #{invalid.to_sentence}." if invalid.any?
      messages << "You're the host, so your own email was skipped." if skipped_self.any?
      messages << "Only the first #{MAX_PER_REQUEST} emails were processed." if truncated
      messages.join(" ").presence
    end
  end

  def initialize(nomikai, inviter:)
    @nomikai = nomikai
    @inviter = inviter
  end

  def call(raw_emails)
    emails = parse(raw_emails)
    result = Result.new(sent: [], already_invited: [], already_joined: [], invalid: [], skipped_self: [],
                        truncated: emails.size > MAX_PER_REQUEST)

    emails.first(MAX_PER_REQUEST).each { |email| invite(email, result) }
    result
  end

  private

  def parse(raw_emails)
    raw_emails.to_s.split(/[\s,;]+/).map { |email| email.strip.downcase }.compact_blank.uniq
  end

  def invite(email, result)
    return result.invalid << email unless email.match?(URI::MailTo::EMAIL_REGEXP)
    return result.skipped_self << email if email == @inviter.email.downcase

    invitation = @nomikai.invitations.find_or_initialize_by(email: email)
    return result.already_joined << email if invitation.accepted?
    return result.already_invited << email if invitation.persisted? && invitation.pending?

    invitation.revoked? ? invitation.reopen! : invitation.save!
    invitation.deliver!
    result.sent << email
  rescue ActiveRecord::RecordNotUnique
    # Two submissions raced on the same address; the other one won.
    result.already_invited << email
  end
end
