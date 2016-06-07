class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy]
  before_filter :load_prospect

  # GET /statements
  # GET /statements.json
  def index
    @statements = @prospect.statements.all
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
  end

  # GET /statements/new
  def new
    @statement = @prospect.statements.new
  end

  # GET /statements/1/edit
  def edit
  end

  # POST /statements
  # POST /statements.json
  def create
    @statement = @prospect.statements.new(statement_params)

    respond_to do |format|
      if @statement.save
        format.html { redirect_to [@prospect, @statement], notice: 'Statement was successfully created.' }
        format.json { render :show, status: :created, location: @statement }
      else
        format.html { render :new }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statements/1
  # PATCH/PUT /statements/1.json
  def update
    respond_to do |format|
      if @statement.update(statement_params)
        format.html { redirect_to [@prospect, @statement], notice: 'Statement was successfully updated.' }
        format.json { render :show, status: :ok, location: @statement }
      else
        format.html { render :edit }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement.destroy
    respond_to do |format|
      format.html { redirect_to prospect_statements_path(@prospect), notice: 'Statement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def load_prospect
      @prospect = Prospect.find(params[:prospect_id])
    end

    def set_statement
      @statement = Statement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_params
      params.require(:statement).permit(:month, :trans_fee, :prospect_id)
    end
end
