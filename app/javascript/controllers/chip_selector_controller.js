import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chip-selector"
export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    this.setupChipButtons()
  }

  setupChipButtons() {
    const chipButtons = this.element.querySelectorAll('.chip-btn')
    chipButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        e.preventDefault()
        this.addChipToBrief(button.dataset.chip)
      })
    })
  }

  addChipToBrief(chipText) {
    const textarea = document.getElementById('campaign_brief')
    if (!textarea) return

    const currentText = textarea.value
    const newText = currentText ? `${currentText} ${chipText}` : chipText
    
    textarea.value = newText
    textarea.focus()
    
    // Trigger input event to update word count
    textarea.dispatchEvent(new Event('input'))
    
    // Visual feedback
    this.highlightChip(chipText)
  }

  highlightChip(chipText) {
    const chipButtons = this.element.querySelectorAll('.chip-btn')
    chipButtons.forEach(button => {
      if (button.dataset.chip === chipText) {
        button.classList.remove('btn-outline-primary')
        button.classList.add('btn-primary')
        
        setTimeout(() => {
          button.classList.remove('btn-primary')
          button.classList.add('btn-outline-primary')
        }, 1000)
      }
    })
  }
}
