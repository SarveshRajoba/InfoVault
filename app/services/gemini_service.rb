require 'httparty'
require 'json'

class GeminiService
  include HTTParty
  base_uri 'https://generativelanguage.googleapis.com/v1beta/models'

  def initialize
    @api_key = ENV['GEMINI_API_KEY'] 
  end

  def generate_questions_and_answers(paragraph)
    # Check if API key is configured
    unless @api_key
      Rails.logger.error "GEMINI_API_KEY environment variable is not set"
      return []
    end

    response = self.class.post(
      "/gemini-2.0-flash:generateContent?key=#{@api_key}",
      headers: { 'Content-Type' => 'application/json' },
      body: { contents: [{ parts: 
      [{ 
        text: "Generate 5 questions and answers from: #{paragraph}, I want the response to be in specific format, There should be no any other text rather than specified format. Format should include only questions and answers with numbers like (Q1: <Question Content>, Answer: <Answer Content>), however there are some more details you need to follow, 1: Questions should be in 10-13 words not more than that. 2: Answers should be in 20-30 words not more than that. 
        
        For Example: 
        Q1: What is the difference between isomers and resonance structures?, 
        Answer: Isomers are different compounds with the same molecular formula, while resonance structures are different representations of the same molecule
        " 
      }] }] }.to_json
    )
    
    Rails.logger.info "Gemini API Response: #{response.body}"  

    # Check if response was successful
    unless response.success?
      Rails.logger.error "Gemini API call failed: #{response.code} - #{response.body}"
      return []
    end

    str = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
    
    # Check if we got a valid response
    unless str
      Rails.logger.error "No valid response text from Gemini API"
      return []
    end

    qa_pairs = str.split("\n\n")

    questions_array = qa_pairs.map.with_index(1) do |pair, index|
      question, answer = pair.split("\nAnswer: ")
      question = question.sub(/,$/, '').sub(/^Q\d+: /, '') 

      { id: index, question: question, answer: answer }.with_indifferent_access

    end

  end
end
