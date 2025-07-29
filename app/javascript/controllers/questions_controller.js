import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    console.log("Questions controller connected")
  }

  async submit(event) {
    event.preventDefault()
    const form = event.target
    const url = form.action
    const formData = new FormData(form)
    
    this.containerTarget.innerHTML = '<div class="loading">Generating questions...</div>'
    
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
      })
      
      const data = await response.json()
      
      if (data.success) {
        this.displayQuestions(data.data)
      } else {
        this.containerTarget.innerHTML = `<div class="error">Error: ${data.error}</div>`
      }
    } catch (error) {
      console.error("Error:", error)
      this.containerTarget.innerHTML = '<div class="error">Failed to generate questions</div>'
    }
  }

  displayQuestions(questionsAndAnswers) {
    const html = questionsAndAnswers.map((qa, index) => `
      <div class="question-card">
        <h3>Question ${index + 1}</h3>
        <p class="question">${qa.question}</p>
        <details>
          <summary>Show Answer</summary>
          <p class="answer">${qa.answer}</p>
        </details>
      </div>
    `).join('')
    
    this.containerTarget.innerHTML = html
  }
}