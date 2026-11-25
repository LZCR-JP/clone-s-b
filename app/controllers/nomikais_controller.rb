class NomikaisController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nomikai, only: %i[show destroy close recommendations recommendations_landing select_candidate]

  def index
    @nomikais = current_user.nomikais
                            .includes(:participants)
                            .order(created_at: :desc)
  end

  def show
    @participants = @nomikai.participants
    @preference_summary = NomikaiPreferenceSummary.new(@nomikai).call
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

  def recommendations
    @places = GooglePlacesSearch.new(@nomikai).call
  end

  def recommendations_landing
    redirect_to nomikai_path(@nomikai),
                notice: "Search results are temporary. Run a new search to refresh them."
  end

  def select_candidate
    candidate = @nomikai.candidates.find(params[:candidate_id])

    @nomikai.with_lock do
      @nomikai.candidates.where.not(id: candidate.id).update_all(selected: false)
      candidate.update!(selected: true)
    end

    redirect_to nomikai_path(@nomikai),
                status: :see_other,
                notice: "Restaurant selected."
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
