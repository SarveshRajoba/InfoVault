require 'httparty'
require 'json'

class GeminiService
  include HTTParty
  base_uri 'https://generativelanguage.googleapis.com/v1beta/models'

  def initialize
    @api_key = ENV["GEMINI_API_KEY"]
  end

  def generate_questions_and_answers(paragraph, number)
    response = self.class.post(
      "/gemini-2.0-flash:generateContent?key=#{@api_key}",
      headers: { 'Content-Type' => 'application/json' },
      body: { contents: [{ parts:
      [{
        text: "Generate #{number} questions and answers from: #{paragraph}, I want the response to be in specific format, There should be no any other text rather than specified format. Format should include only questions and answers with numbers like (Q1: <Question Content>, Answer: <Answer Content>), however there are some more details you need to follow, 1: Questions should be in 10-13 words not more than that. 2: Answers should be in 20-30 words not more than that.
        For Example:
        Q1: What is the difference between isomers and resonance structures?,
        Answer: Isomers are different compounds with the same molecular formula, while resonance structures are different representations of the same molecule
        "
      }] }] }.to_json
    )
    Rails.logger.info "Gemini API Response: #{response.body}"

    # Parse the JSON response first
    response_data = JSON.parse(response.body)
    str = response_data.dig('candidates', 0, 'content', 'parts', 0, 'text')

    Rails.logger.info "Raw text from Gemini: #{str}"

    return [] unless str.present?

    # Split by double newlines first, then handle single newlines
    qa_pairs = str.split(/\n\n+/)
    Rails.logger.info "QA pairs after split: #{qa_pairs.inspect}"

    questions_array = qa_pairs.map.with_index(1) do |pair, index|
      Rails.logger.info "Processing pair #{index}: #{pair}"

      question = nil
      answer = nil

      # Pattern 1: Q1: question\nAnswer: answer
      if pair.match(/^Q\d+:\s*(.+?)\nAnswer:\s*(.+)$/m)
        question = $1.strip
        answer = $2.strip
      # Pattern 2: Q1: question, Answer: answer
      elsif pair.match(/^Q\d+:\s*(.+?),\s*Answer:\s*(.+)$/)
        question = $1.strip
        answer = $2.strip
      # Pattern 3: Just split by newline if Answer: is present
      elsif pair.include?("Answer:")
        parts = pair.split("Answer:")
        question = parts[0].sub(/^Q\d+:\s*/, '').strip
        answer = parts[1].strip
      else
        Rails.logger.warn "Could not parse pair #{index}: #{pair}"
        next
      end

      # Clean up the question and answer
      question = question.sub(/,$/, '').sub(/^Q\d+:\s*/, '').strip
      answer = answer.strip

      Rails.logger.info "Extracted - Question: '#{question}', Answer: '#{answer}'"

      next if question.blank? || answer.blank?

      { id: index, question: question, answer: answer }.with_indifferent_access
    end.compact

    Rails.logger.info "Final questions array: #{questions_array.inspect}"
    questions_array
  end
end
