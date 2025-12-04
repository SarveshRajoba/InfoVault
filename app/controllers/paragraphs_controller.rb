class ParagraphsController < ApplicationController
  before_action :authenticate_user
  before_action :set_subject
  before_action :set_chapter
  before_action :set_paragraph, only: [:show, :update, :destroy, :edit]

  def index
    @paragraphs = @chapter.paragraphs.order(updated_at: :desc)
    @chapter = Chapter.find(params[:chapter_id])
    @subject = @chapter.subject
    if params[:search].present?
      @paragraphs = @paragraphs.where("title ILIKE ?", "%#{params[:search]}%")
    end
  end

  def show
    @questions = @paragraph.questions.includes(:answers)
  end
  
  def create
    @paragraph = @chapter.paragraphs.new(paragraph_params)
    @paragraph.user = current_user
    if @paragraph.save
      res = generate_questions_and_answers(@paragraph, @paragraph.num_questions)
      
      redirect_to subject_chapter_paragraphs_path(@chapter.subject, @chapter), notice: "Paragraph created successfully!!" 
    else
      redirect_to subject_chapter_paragraphs_path, alert: flash[:alert] = @paragraph.errors.full_messages.to_sentence
    end
  end

  def edit
    redirect_to subject_chapter_paragraphs_path
  end

  def update
    if @paragraph.update(paragraph_params)
      if @paragraph.saved_change_to_content?
        @paragraph.questions.destroy_all
        res = generate_questions_and_answers(@paragraph, @paragraph.num_questions)
      end
      redirect_to subject_chapter_paragraphs_path(@chapter.subject, @chapter), notice: "Paragraph updated successfully."
    else
      redirect_to subject_chapter_paragraphs_path, alert: "Something went wrong!!"
    end
  end

  def destroy
    if @paragraph.destroy
      redirect_to subject_chapter_paragraphs_path(@chapter.subject, @chapter), notice: "Paragraph deleted successfully!!"
    else
      redirect_to subject_chapter_paragraph_path(@chapter.subject, @chapter, @paragraph), alert: "Failed to delete paragraph."
    end
  end

  private

  def paragraph_params
    params.require(:paragraph).permit(:title, :content, :num_questions)
  end


  def set_subject
    @subject = current_user.subjects.find_by(id: params[:subject_id])
    unless @subject
      redirect_to subjects_path, notice: "Subject not found!!"
      return false
    end 
  end

  def set_chapter
    return unless @subject
    @chapter = @subject.chapters.find_by(id: params[:chapter_id])
    unless @chapter
      redirect_to subject_chapters_path(@subject), notice: "Chapter not found!!"
      return false
    end
  end
  
  def set_paragraph
    return unless @chapter
    if current_user.presence
      @paragraph = @chapter.paragraphs.find_by(id: params[:id])
    else
      redirect_to login_path, notice: "Something went wrong!!"
      return false
    end
    unless @paragraph
      redirect_to subject_chapter_paragraphs_path(@subject, @chapter), notice: "Paragraph not found!!"
      return false
    end
  end
  
  def authenticate_user
    unless current_user
      redirect_to login_path, notice: "You need to login first"
      return false
    end
  end


  def generate_questions_and_answers(paragraph, num_questions = 5)
    gemini_service = GeminiService.new 
    response_text = gemini_service.generate_questions_and_answers(paragraph.content, num_questions)
  
    if response_text.present?
      begin
          response_text.map do |h|
            question = paragraph.questions.create!(question: h[:question])
            question.answers.create!(answer: h[:answer])
          end
    
      rescue => e
        Rails.logger.error "Error parsing questions & answers: #{e.message}"
      end
    else
      Rails.logger.error "No response from Gemini API"
    end
  end
end
