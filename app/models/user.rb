class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  attr_accessor :email

  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :prospects, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :programusers, dependent: :destroy
  has_many :programs, through: :programusers
  has_many :processorusers, dependent: :destroy
  has_many :processors, through: :processorusers
  has_many :courseusers, dependent: :destroy
  has_many :chapterusers, dependent: :destroy
  has_many :lessonusers, dependent: :destroy
  belongs_to :subscribetocourses
  has_many :tickets, dependent: :destroy
  has_many :team_users, dependent: :destroy
  has_many :teams, through: :team_users

  after_create :create_notification, :add_programs, :make_subscribed, :create_affiliate_relationship
  after_destroy :cancel_notification


  def stripe_subscribed?
    stripe_subscription_id?
  end

  def make_subscribed
    self.subscribed = true
    self.training_subscribed = true
    self.save
  end

  def create_notification
    AdminMailer.new_user(self).deliver
  end

  def cancel_notification
    AdminMailer.cancelled_user(self).deliver
  end

  def create_affiliate_relationship
    @team = Team.find_by_id(params[:team_id])
    if @team.team_type.description == "Affiliate" && self.invited_by_id != nil
      @team_user = TeamUser.new
      @team_user.team_id = @team.id
      @team_user.user_id = self.id
    end
  end

  def add_programs
    @programs = Program.all.where(personal: false)
    @programs.each do |program|
      @programuser = Programuser.new
      @programuser.user_id = self.id
      @programuser.program_id = program.id
      @programuser.save!
    end

    @processors = Processor.all.where(personal: false)
    @processors.each do |processor|
      @processoruser = Processoruser.new
      @processoruser.user_id = self.id
      @processoruser.processor_id = processor.id
      @processoruser.save!
    end
  end
end


