class GenerateQuestionsJob < ApplicationJob
  queue_as :default

  def perform(paragraph_id, num_questions = 5)
    paragraph = Paragraph.find_by(id: paragraph_id)
    return unless paragraph

    groq_service = GroqService.new
    response_text = groq_service.generate_questions_and_answers(paragraph.content, num_questions)
    if response_text.present?
      begin
        response_text.each do |h|
          question = paragraph.questions.create!(question: h[:question])
          question.answers.create!(answer: h[:answer])
        end
      rescue => e
        Rails.logger.error "Error parsing questions & answers: #{e.message}"
      end
    else
      Rails.logger.error "No response from AI API"
    end
  end
end
