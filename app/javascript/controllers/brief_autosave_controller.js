import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="brief-autosave"
export default class extends Controller {
  static targets = ["textarea"]
  static values = { 
    url: String,
    interval: { type: Number, default: 30000 } // 30 seconds default
  }

  connect() {
    this.timeout = null
    this.setupWordCount()
    this.setupAutosave()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  setupWordCount() {
    this.updateWordCount()
    this.textareaTarget.addEventListener('input', () => {
      this.updateWordCount()
      this.scheduleAutosave()
    })
  }

  setupAutosave() {
    // Autosave every interval
    setInterval(() => {
      if (this.textareaTarget.value.trim().length > 0) {
        this.saveDraft()
      }
    }, this.intervalValue)
  }

  scheduleAutosave() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    
    this.timeout = setTimeout(() => {
      if (this.textareaTarget.value.trim().length > 0) {
        this.saveDraft()
      }
    }, 2000) // Save 2 seconds after user stops typing
  }

  updateWordCount() {
    const text = this.textareaTarget.value
    const words = text.trim().split(/\s+/).filter(word => word.length > 0).length
    const chars = text.length

    const wordCountElement = document.getElementById('word-count')
    const charCountElement = document.getElementById('char-count')
    
    if (wordCountElement) wordCountElement.textContent = words
    if (charCountElement) charCountElement.textContent = chars
  }

  async saveDraft() {
    try {
      const response = await fetch(this.urlValue || window.location.pathname, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          campaign: {
            brief: this.textareaTarget.value
          }
        })
      })

      if (response.ok) {
        this.showSaveIndicator('saved')
      } else {
        this.showSaveIndicator('error')
      }
    } catch (error) {
      console.error('Autosave failed:', error)
      this.showSaveIndicator('error')
    }
  }

  showSaveIndicator(status) {
    const indicator = document.getElementById('save-indicator')
    if (!indicator) return

    indicator.textContent = status === 'saved' ? 'Saved' : 'Error saving'
    indicator.className = `small ${status === 'saved' ? 'text-success' : 'text-danger'}`
    
    setTimeout(() => {
      indicator.textContent = ''
      indicator.className = 'small'
    }, 2000)
  }
}
