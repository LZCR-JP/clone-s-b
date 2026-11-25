class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nomikai
  before_action :set_invitation, only: %i[resend destroy]

  def create
    unless @nomikai.accepting_participants?
      flash[:invite_alert] = "This event is no longer accepting new teammates."
      return redirect_back_to_invites
    end

    result = InvitationSender.new(@nomikai, inviter: current_user).call(params[:emails])
    flash[:invite_notice] = result.notice
    flash[:invite_alert] = result.alert

    redirect_back_to_invites
  end

  def resend
    if !@invitation.pending?
      flash[:invite_alert] = "Only pending invites can be resent."
    elsif @invitation.recently_sent?
      flash[:invite_alert] = "Invite to #{@invitation.email} was just sent. Please wait a minute before resending."
    else
      @invitation.deliver!
      flash[:invite_notice] = "Invite resent to #{@invitation.email}."
    end

    redirect_back_to_invites
  end

  def destroy
    if @invitation.pending?
      @invitation.revoke!
      flash[:invite_notice] = "Invite to #{@invitation.email} was revoked."
    else
      flash[:invite_alert] = "#{@invitation.email} has already joined, so the invite can't be revoked."
    end

    redirect_back_to_invites
  end

  private

  def set_nomikai
    @nomikai = current_user.nomikais.find(params[:nomikai_id])
  end

  def set_invitation
    @invitation = @nomikai.invitations.find(params[:id])
  end

  def redirect_back_to_invites
    redirect_to nomikai_path(@nomikai, tab: "email", anchor: "invite"), status: :see_other
  end
end
