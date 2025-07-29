class SubjectsController < ApplicationController
  before_action :authenticate_user
  before_action :set_subject, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to subjects_path if request.fullpath == "/"

    if current_user.present?
      @subjects = current_user.subjects.order(created_at: :desc)
    else
      redirect_to login_path, notice: "Login required"
    end
    if params[:search].present?
      @subjects = current_user.subjects.where("name ILIKE ?", "%#{params[:search]}%")
    end
    @subject = Subject.new
  end

  def show
    begin
      @chapters = @subject.chapters
      redirect_to subject_chapters_path(@subject.id)
    rescue ActiveRecord::RecordNotFound
      redirect_to subjects_path, notice: "Subject not found"
    end
  end

  def create
    @subject = current_user.subjects.build(subject_params)
    if @subject.save
      redirect_to subjects_path, notice: "Subject was created successfully"
    else
      redirect_to subjects_path, alert: @subject.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @subject.update(subject_params)
      redirect_to subjects_path, notice: "Subject updated successfully!!"
    else
      render :edit, alert: @subject.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @subject
      @subject.destroy
      redirect_to subjects_path, notice: "Subject deleted Successfully", status: :found
    else
      redirect_to subjects_path, alert: "Subject not found or you don't have permission"
    end
  end

  private

  def subject_params
    params.require(:subject).permit(:name)
  end

  def set_subject
    if current_user.present?
      @subject = current_user.subjects.find_by(id: params[:id])
      unless @subject
        redirect_to subjects_path, alert: "Subject not found or you don't have permission"
        return false
      end
    else
      redirect_to login_path, alert: @subject.erros.full_messages.to_sentence
    end
  end

  def authenticate_user
    unless current_user
      redirect_to login_path, notice: "You need to login first"
      return false
    end
  end
end