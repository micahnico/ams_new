class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_subscribed
  def index
    @prospects = current_user.prospects
    @tasks = current_user.tasks
    @grouped_tasks = @tasks.group_by(&:finish_date)
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @sorted_tasks = @tasks.sort_by{ |t| t.finish_date }
    @completed_tasks = @sorted_tasks.select { |task| task.completed? == true }
    @uncompleted_tasks = @sorted_tasks.select { |task| task.completed? == false }
    @next_task =  @uncompleted_tasks.first
  end

end
