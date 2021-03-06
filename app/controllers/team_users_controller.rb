class TeamUsersController < ApplicationController
  before_action :set_team_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :require_admin, only: [:index]
  before_action :set_team, except: [:show]

  # GET /team_users
  # GET /team_users.json
  def index
    @team_users = TeamUser.all
  end

  # GET /team_users/1
  # GET /team_users/1.json
  def show
  end

  # GET /team_users/new
  def new
    @team_user = TeamUser.new
  end

  # GET /team_users/1/edit
  def edit
  end

  # POST /team_users
  # POST /team_users.json
  def create
    @team_user = @team.team_users.new(team_user_params)
    @team_user.team = @team

    respond_to do |format|
      if @team_user.save
        @team_users = TeamUser.where(user_id: @team_user.user_id).where("team_id != ?", @team_user.team_id)
        if @team_users.empty? || @team.team_type_id == 2 || @team.team_type_id == 1
          format.html { redirect_to team_path(@team), notice: 'Team user was successfully created.' }
        else 
          @team_user.delete 
          format.html { redirect_to team_path(@team), notice: 'User Already on Another Team - Contact support@instantquotetool.com' }
        end
      else
        format.html { redirect_to team_path(@team), notice: "User is Already Associated with #{@team.name} Team" }
        format.json { render json: @team_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /team_users/1
  # PATCH/PUT /team_users/1.json
  def update
    respond_to do |format|
      if @team_user.update(team_user_params)
        format.html { redirect_to @team_user, notice: 'Team user was successfully updated.' }
        format.json { render :show, status: :ok, location: @team_user }
      else
        format.html { render :edit }
        format.json { render json: @team_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /team_users/1
  # DELETE /team_users/1.json
  def destroy
    @team_user.destroy
    respond_to do |format|
      format.html { redirect_to team_users_url, notice: 'Team user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team_user
      @team_user = TeamUser.find(params[:id])
    end

    def set_team
      @team = Team.find(params[:team_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_user_params
      params.require(:team_user).permit(:email, :user_id, :team_id, :team_user_role_id)
    end
    

end
