class ChaptersController < ApplicationController

	before_action :authenticate_user
	before_action :set_subject
	before_action :set_chapter, only: [:show, :update, :destroy, :edit]


	def index
		@chapters = @subject.chapters.order(created_at: :desc)
		@chapters = @chapters.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
	end
	
	def show
		@subject = Subject.find(params[:subject_id])
		@chapter = @subject.chapters.find(params[:id])
		redirect_to subject_chapter_paragraphs_path(@subject.id, @chapter.id)
	end

	def create
		@chapter = @subject.chapters.new(chapter_params)
		if @chapter.save
			redirect_to subject_chapters_path(@subject), notice: "Chapter created successfully!!"
		else
			redirect_to subject_chapters_path, status: :found, alert: @chapter.errors.full_messages.to_sentence
		end
	end

	def edit
		@subject = Subject.find(params[:subject_id])
		@chapter = @subject.chapters.find(params[:id])
		redirect_to subject_chapters_path
	end

	def update
		if @chapter.update(chapter_params)
			redirect_to subject_chapters_path(@subject), notice: "Chapter updated successfully!!"
		else
			redirect_to subject_chapters_path, status: :found
		end
	end

	def destroy		
		@chapter.destroy
		redirect_to subject_chapters_path(@subject), notice: "Chapter deleted successfully!!", status: :found
	end

	private

	def set_subject
		@subject = current_user.subjects.find_by(id: params[:subject_id])
		unless @subject
			redirect_to subjects_path, notice: "Subject not found!!"
			return false
		end
	end

	def set_chapter
		return unless params[:id]
		@chapter = @subject.chapters.find_by(id: params[:id])
		unless @chapter
			redirect_to subject_chapters_path(@subject), notice: "Chapter not found!!"
			return false
		end
	end

	def chapter_params
		params.require(:chapter).permit(:name)
	end

	def authenticate_user
    unless current_user
      redirect_to login_path, notice: "You need to login first"
			return false
    end
  end

end
