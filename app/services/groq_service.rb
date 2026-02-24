require "httparty"
require "json"

class GroqService
  include HTTParty
  base_uri "https://api.groq.com/openai/v1"

  def initialize
    @api_key = ENV["GROQ_API_KEY"]
  end

  def generate_questions_and_answers(paragraph, num_questions = 5)
    return [] if num_questions == 0

    unless @api_key
      Rails.logger.error "GROQ_API_KEY environment variable is not set"
      return []
    end

    response = self.class.post(
      "/chat/completions",
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      },
      body: {
        model: "llama-3.3-70b-versatile",
        messages: [
          {
            role: "user",
            content: "Generate exactly #{num_questions} questions and answers based on the following text. Format ONLY as shown below with a blank line between each pair. No other text, no preamble, no numbering beyond Q1/Q2 etc:\n\nQ1: <Question in 10-13 words>\nAnswer: <Answer in 20-30 words>\n\nQ2: <Question in 10-13 words>\nAnswer: <Answer in 20-30 words>\n\nText:\n#{paragraph}"
          }
        ],
        temperature: 0.3,
        max_tokens: num_questions * 200 + 500
      }.to_json
    )

    unless response.success?
      Rails.logger.error "Groq API call failed: #{response.code} - #{response.body}"
      return []
    end

    str = response.dig("choices", 0, "message", "content")

    unless str.present?
      Rails.logger.error "No valid response text from Groq API"
      return []
    end

    Rails.logger.info "Groq response: #{str}"

    # Parse Q/A pairs — each separated by blank line
    qa_pairs = str.strip.split(/\n\n+/)
    questions_array = qa_pairs.filter_map do |pair|
      next if pair.strip.empty?
      lines = pair.strip.split("\n")
      q_line = lines.find { |l| l.match?(/^Q\d+:/i) }
      a_line = lines.find { |l| l.match?(/^Answer:/i) }
      next unless q_line && a_line

      question = q_line.sub(/^Q\d+:\s*/i, "").strip
      answer   = a_line.sub(/^Answer:\s*/i, "").strip
      { question: question, answer: answer }.with_indifferent_access
    end

    questions_array
  end
end
