require "test_helper"

class InvitationSenderTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @host = create_host
    @nomikai = create_nomikai(user: @host)
    @sender = InvitationSender.new(@nomikai, inviter: @host)
  end

  test "sends invites for valid, deduplicated emails" do
    result = nil
    assert_enqueued_emails 2 do
      result = @sender.call("Aiko@Example.com, ken@example.com\naiko@example.com")
    end

    assert_equal %w[aiko@example.com ken@example.com], result.sent
    assert_equal 2, @nomikai.invitations.where(status: "pending").count
    assert result.notice.present?
  end

  test "sorts invalid, duplicate, joined and self emails into buckets" do
    @nomikai.invitations.create!(email: "pending@example.com")
    @nomikai.invitations.create!(email: "joined@example.com", status: "accepted")

    result = @sender.call("pending@example.com joined@example.com nope host@example.com")

    assert_empty result.sent
    assert_equal ["pending@example.com"], result.already_invited
    assert_equal ["joined@example.com"], result.already_joined
    assert_equal ["nope"], result.invalid
    assert_equal ["host@example.com"], result.skipped_self
    assert_match "Already invited", result.alert
  end

  test "re-inviting a revoked email reopens it with a fresh token" do
    invitation = @nomikai.invitations.create!(email: "back@example.com", status: "revoked")
    old_token = invitation.token

    result = @sender.call("back@example.com")

    assert_equal ["back@example.com"], result.sent
    invitation.reload
    assert invitation.pending?
    assert_not_equal old_token, invitation.token
  end

  test "blank input is reported" do
    assert_equal "Enter at least one email address.", @sender.call("  ").alert
  end

  test "caps the number of emails per request" do
    emails = (1..25).map { |i| "t#{i}@example.com" }.join(",")
    result = @sender.call(emails)

    assert_equal InvitationSender::MAX_PER_REQUEST, result.sent.size
    assert result.truncated
  end
end
