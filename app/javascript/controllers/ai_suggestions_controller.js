import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai-suggestions"
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.setupButton()
  }

  setupButton() {
    this.element.addEventListener('click', (e) => {
      e.preventDefault()
      this.generateSuggestions()
    })
  }

  async generateSuggestions() {
    const briefText = document.getElementById('campaign_brief')?.value
    
    if (!briefText || briefText.trim().length < 20) {
      this.showError('Please enter a brief with at least 20 characters before getting AI suggestions.')
      return
    }

    this.setLoadingState(true)
    
    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      const data = await response.json()
      
      if (response.ok) {
        this.displaySuggestions(data.suggestions)
      } else {
        this.showError(data.error || 'Failed to generate suggestions')
      }
    } catch (error) {
      console.error('AI suggestions error:', error)
      this.showError('Unable to generate suggestions at this time')
    } finally {
      this.setLoadingState(false)
    }
  }

  displaySuggestions(suggestions) {
    // Create modal or inline suggestions display
    this.createSuggestionsModal(suggestions)
  }

  createSuggestionsModal(suggestions) {
    const modalHtml = `
      <div class="modal fade" id="aiSuggestionsModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">
                <i class="bi bi-magic me-2"></i>
                AI Suggestions for Your Campaign Brief
              </h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              ${this.formatSuggestions(suggestions)}
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
              <button type="button" class="btn btn-primary" data-bs-dismiss="modal" data-action="click->ai-suggestions#applySuggestions">Apply Suggestions</button>
            </div>
          </div>
        </div>
      </div>
    `

    // Remove existing modal if any
    const existingModal = document.getElementById('aiSuggestionsModal')
    if (existingModal) {
      existingModal.remove()
    }

    // Add modal to page
    document.body.insertAdjacentHTML('beforeend', modalHtml)
    
    // Store suggestions for later use
    this.suggestions = suggestions
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('aiSuggestionsModal'))
    modal.show()
  }

  formatSuggestions(suggestions) {
    if (!suggestions || typeof suggestions !== 'object') {
      return '<p class="text-muted">No suggestions available at this time.</p>'
    }

    let html = ''
    
    Object.entries(suggestions).forEach(([key, value]) => {
      html += `
        <div class="mb-4">
          <h6 class="fw-bold text-primary">${this.formatSuggestionTitle(key)}</h6>
          <div class="bg-light p-3 rounded">
            <p class="mb-0">${value}</p>
          </div>
        </div>
      `
    })
    
    return html
  }

  formatSuggestionTitle(key) {
    const titles = {
      'headline': 'Enhanced Headline',
      'value_proposition': 'Value Proposition',
      'call_to_action': 'Call to Action',
      'audience_targeting': 'Audience Targeting',
      'goals': 'Campaign Goals'
    }
    
    return titles[key] || key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
  }

  applySuggestions() {
    // This would apply the suggestions to the form fields
    // For now, just show a success message
    this.showSuccess('Suggestions applied! You can now refine your brief.')
  }

  setLoadingState(loading) {
    const originalText = this.element.innerHTML
    
    if (loading) {
      this.element.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Generating...'
      this.element.disabled = true
      this.element.classList.add('disabled')
    } else {
      this.element.innerHTML = originalText
      this.element.disabled = false
      this.element.classList.remove('disabled')
    }
  }

  showError(message) {
    this.showAlert(message, 'danger')
  }

  showSuccess(message) {
    this.showAlert(message, 'success')
  }

  showAlert(message, type) {
    const alertHtml = `
      <div class="alert alert-${type} alert-dismissible fade show position-fixed" style="top: 20px; right: 20px; z-index: 9999; max-width: 400px;">
        <i class="bi bi-${type === 'danger' ? 'exclamation-triangle' : 'check-circle'} me-2"></i>
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    `
    
    document.body.insertAdjacentHTML('beforeend', alertHtml)
    
    // Auto-dismiss after 5 seconds
    setTimeout(() => {
      const alert = document.querySelector('.alert')
      if (alert) {
        const bsAlert = new bootstrap.Alert(alert)
        bsAlert.close()
      }
    }, 5000)
  }
}
