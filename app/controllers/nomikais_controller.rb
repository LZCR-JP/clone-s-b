class NomikaisController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nomikai, only: %i[show destroy close regenerate_code]

  def index
    @nomikais = current_user.nomikais
                            .includes(:participants)
                            .order(created_at: :desc)
  end

  def show
    @participants = @nomikai.participants
    @invitations = @nomikai.invitations.visible.order(created_at: :desc)
  end

  def new
    @nomikai = Nomikai.new
  end

  def create
    @nomikai = current_user.nomikais.build(nomikai_params)

    if @nomikai.save
      VibeCardSelector.new(@nomikai).call

      redirect_to nomikai_path(@nomikai),
                  notice: "Nomikai successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @nomikai = current_user.nomikais.find(params[:id])
  end

  def update
    @nomikai = current_user.nomikais.find(params[:id])

    if @nomikai.update(nomikai_params)
      redirect_to nomikai_path(@nomikai),
                  notice: "Gathering successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @nomikai.destroy!

    redirect_to nomikais_path,
                status: :see_other,
                notice: "Nomikai deleted."
  end

  def close
    @nomikai.update!(status: "closed")

    redirect_to nomikai_path(@nomikai),
                status: :see_other,
                notice: "Nomikai is now closed."
  end

  def regenerate_code
    @nomikai.regenerate_join_code!
    flash[:invite_notice] = "New join code created. The old code no longer works."

    redirect_to nomikai_path(@nomikai, anchor: "invite"), status: :see_other
  end

  private

  def set_nomikai
    @nomikai = current_user.nomikais.find(params[:id])
  end

  def nomikai_params
    params.require(:nomikai).permit(
      :name,
      :area,
      :latitude,
      :longitude,
      :event_date,
      :group_size,
      :budget_per_person
    )
  end
end
