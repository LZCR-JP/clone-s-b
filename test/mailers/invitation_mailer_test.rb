require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  test "invite includes the personal link and join code" do
    nomikai = create_nomikai
    invitation = nomikai.invitations.create!(email: "aiko@example.com")

    mail = InvitationMailer.with(invitation: invitation).invite

    assert_equal ["aiko@example.com"], mail.to
    assert_match nomikai.name, mail.subject
    assert_match "/invite/#{invitation.token}", mail.body.encoded
    assert_match nomikai.formatted_join_code, mail.body.encoded
  end
end
