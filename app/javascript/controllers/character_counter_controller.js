import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "count", "status"]

  connect() {
    this.updateCount()
    this.inputElement.addEventListener('input', this.updateCount.bind(this))
  }

  disconnect() {
    this.inputElement.removeEventListener('input', this.updateCount.bind(this))
  }

  get inputElement() {
    return this.textareaTarget
  }

  updateCount() {
    const text = this.inputElement.value
    const count = text.length
    const maxLength = parseInt(this.inputElement.getAttribute('maxlength')) || 1000
    
    // Update count display
    if (this.hasCountTarget) {
      this.countTarget.textContent = count
    }
    
    // Update status
    if (this.hasStatusTarget) {
      const remaining = maxLength - count
      if (remaining < 0) {
        this.statusTarget.textContent = `${Math.abs(remaining)} over limit`
        this.statusTarget.className = 'text-muted small text-danger'
      } else if (remaining <= 10) {
        this.statusTarget.textContent = `${remaining} remaining`
        this.statusTarget.className = 'text-muted small text-warning'
      } else {
        this.statusTarget.textContent = ''
        this.statusTarget.className = 'text-muted small'
      }
    }
    
    // Update field styling
    if (count > maxLength) {
      this.inputElement.classList.add('is-invalid')
      this.inputElement.classList.remove('is-valid')
    } else if (count > 0) {
      this.inputElement.classList.add('is-valid')
      this.inputElement.classList.remove('is-invalid')
    } else {
      this.inputElement.classList.remove('is-valid', 'is-invalid')
    }
  }
}
