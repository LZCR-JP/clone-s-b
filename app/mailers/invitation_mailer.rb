class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @nomikai = @invitation.nomikai
    @host_name = @nomikai.user.name

    mail to: @invitation.email,
         subject: "#{@host_name} invited you to #{@nomikai.name} on Swipe & Bite"
  end
end
