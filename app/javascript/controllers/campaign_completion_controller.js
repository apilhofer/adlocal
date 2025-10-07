import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progressBar", "percentage"]
  static values = { businessHasBrandProfile: Boolean }

  connect() {
    this.updateProgress()
    // Listen for form changes
    this.element.addEventListener("input", this.updateProgress.bind(this))
    this.element.addEventListener("change", this.updateProgress.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("input", this.updateProgress.bind(this))
    this.element.removeEventListener("change", this.updateProgress.bind(this))
  }

  updateProgress() {
    const completion = this.calculateCompletion()
    
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${completion}%`
      
      // Update progress bar color based on completion
      this.progressBarTarget.className = `progress-bar ${completion === 100 ? 'bg-success' : 'bg-primary'}`
    }
    
    if (this.hasPercentageTarget) {
      this.percentageTarget.textContent = `${completion}%`
      this.percentageTarget.className = `badge ${completion === 100 ? 'bg-success' : 'bg-secondary'}`
    }
  }

  calculateCompletion() {
    let completedFields = 0
    const totalFields = 9

    // Campaign name
    if (this.getFieldValue("campaign_name").trim() !== "") {
      completedFields++
    }

    // Status (defaults to draft, so always complete)
    completedFields++

    // Brief
    if (this.getFieldValue("campaign_brief").trim().length >= 20) {
      completedFields++
    }

    // Goals
    if (this.getFieldValue("campaign_goals").trim() !== "") {
      completedFields++
    }

    // Audience
    if (this.getFieldValue("campaign_audience").trim() !== "") {
      completedFields++
    }

    // Offer
    if (this.getFieldValue("campaign_offer").trim() !== "") {
      completedFields++
    }

    // CTA
    if (this.getFieldValue("campaign_cta").trim() !== "") {
      completedFields++
    }

    // Ad sizes (check if any checkboxes are checked)
    const adSizeCheckboxes = this.element.querySelectorAll('input[name="campaign[ad_sizes][]"]:checked')
    if (adSizeCheckboxes.length > 0) {
      completedFields++
    }

    // Brand profile (check if business has defaults or campaign has overrides)
    const hasBrandColors = this.getFieldValue("brand_colors").trim() !== "" || this.businessHasBrandProfileValue
    const hasBrandFonts = this.getFieldValue("brand_fonts").trim() !== "" || this.businessHasBrandProfileValue
    const hasToneWords = this.getFieldValue("tone_words").trim() !== "" || this.businessHasBrandProfileValue

    if (hasBrandColors && hasBrandFonts && hasToneWords) {
      completedFields++
    }

    return Math.round((completedFields / totalFields) * 100)
  }

  getFieldValue(fieldId) {
    const field = this.element.querySelector(`#${fieldId}`)
    return field ? field.value : ""
  }
}
