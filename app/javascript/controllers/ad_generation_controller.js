import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["button", "progress", "progressBar", "status", "variants", "error"]
  static values = { campaignId: Number }

  connect() {
    console.log("Ad generation controller connected")
    this.isGenerating = false
    
    // Initialize ActionCable subscription
    this.initializeActionCable()
  }

  initializeActionCable() {
    console.log("Initializing ActionCable...")
    console.log("createConsumer available:", typeof createConsumer !== 'undefined')
    console.log("Campaign ID:", this.campaignIdValue)
    
    try {
      this.consumer = createConsumer()
      console.log("✅ Created ActionCable consumer:", this.consumer)
      
      this.subscription = this.consumer.subscriptions.create(
        { 
          channel: "AdGenerationChannel", 
          campaign_id: this.campaignIdValue 
        },
        {
          connected: () => {
            console.log("✅ ActionCable connected for campaign", this.campaignIdValue)
          },
          disconnected: () => {
            console.log("❌ ActionCable disconnected")
          },
          received: (data) => {
            console.log("📨 Received ActionCable message:", data)
            console.log("Message type:", data.type)
            console.log("Message data:", JSON.stringify(data, null, 2))
            this.handleMessage(data)
          },
          rejected: () => {
            console.log("❌ ActionCable subscription rejected")
          }
        }
      )
      console.log("✅ Created subscription:", this.subscription)
    } catch (error) {
      console.error("❌ Failed to initialize ActionCable:", error)
      console.warn("❌ ActionCable not available, real-time updates disabled")
    }
  }


  disconnect() {
    // Cleanup ActionCable subscription
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  handleMessage(data) {
    console.log("🔧 Handling ActionCable message:", data)
    console.log("Message type:", data.type)
    
    switch(data.type) {
      case "progress":
        console.log("📊 Progress update:", data.percentage + "% - " + data.message)
        this.updateProgress(data.percentage)
        this.updateStatus(data.message)
        break
      case "variant_update":
        console.log("🔄 Variant update received:", data.variant)
        break
      case "completion":
        console.log("✅ Completion received with variants:", data.variants)
        this.updateProgress(100)
        this.updateStatus("Ad generation completed!")
        this.renderVariants(data.variants)
        this.resetButton()
        break
      case "error":
        console.log("❌ Error received:", data.error)
        this.showError(data.error)
        this.resetButton()
        break
      default:
        console.log("❓ Unknown message type:", data.type)
    }
  }

  generateAds(event) {
    event.preventDefault()
    
    if (this.isGenerating) return
    
    this.isGenerating = true
    this.updateButtonState(true)
    this.showProgress(true)
    this.clearVariants()
    this.clearError()
    
    fetch(`/campaigns/${this.campaignIdValue}/generate_ads`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === "started") {
        this.updateStatus("Ad generation started...")
        this.updateProgress(10)
        // Real-time updates will come via ActionCable
      } else if (data.error) {
        this.showError(data.error)
        this.resetButton()
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showError("Failed to start ad generation")
      this.resetButton()
    })
  }



  updateButtonState(isGenerating) {
    if (isGenerating) {
      this.buttonTarget.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Generating...'
      this.buttonTarget.disabled = true
      this.buttonTarget.classList.add('btn-secondary')
      this.buttonTarget.classList.remove('btn-outline-primary')
    } else {
      this.buttonTarget.innerHTML = '<i class="bi bi-magic me-2"></i>Generate Ads'
      this.buttonTarget.disabled = false
      this.buttonTarget.classList.remove('btn-secondary')
      this.buttonTarget.classList.add('btn-outline-primary')
    }
  }

  showProgress(show) {
    this.progressTarget.style.display = show ? 'block' : 'none'
  }

  updateProgress(percentage) {
    this.progressBarTarget.style.width = `${percentage}%`
    this.progressBarTarget.setAttribute('aria-valuenow', percentage)
  }

  updateStatus(message) {
    this.statusTarget.textContent = message
  }

  showError(message) {
    this.errorTarget.innerHTML = `
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle me-2"></i>
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    `
  }

  clearError() {
    this.errorTarget.innerHTML = ''
  }

  clearVariants() {
    this.variantsTarget.innerHTML = ''
  }

  renderVariants(variants) {
    console.log("🎨 Rendering variants:", variants)
    console.log("Variants count:", variants.length)
    console.log("Variants target:", this.variantsTarget)
    
    variants.forEach((variant, index) => {
      console.log(`Creating variant ${index + 1}:`, variant)
      const variantHtml = this.createVariantCard(variant)
      console.log("Variant HTML:", variantHtml)
      this.variantsTarget.insertAdjacentHTML('beforeend', variantHtml)
    })
    
    console.log("✅ All variants rendered")
  }

  createVariantCard(variant) {
    return `
      <div class="col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header bg-white border-bottom">
            <div class="d-flex justify-content-between align-items-center">
              <h6 class="mb-0 fw-bold">${variant.ad_size}</h6>
              <span class="badge bg-success">Completed</span>
            </div>
            <small class="text-muted">Variant ${variant.variant_id}</small>
          </div>
          <div class="card-body d-flex flex-column">
            ${variant.image_url ? `<img src="${variant.image_url}" class="img-fluid rounded mb-3" style="max-height: 150px; object-fit: cover;">` : ''}
            <h6 class="fw-bold">${variant.headline}</h6>
            <p class="text-muted small mb-2">${variant.subheadline}</p>
            <div class="mt-auto">
              <div class="d-grid">
                <button class="btn btn-outline-primary btn-sm">${variant.call_to_action}</button>
              </div>
            </div>
          </div>
          <div class="card-footer bg-light">
            <small class="text-muted">
              <i class="bi bi-lightbulb me-1"></i>
              ${variant.reasoning ? variant.reasoning.substring(0, 80) + '...' : ''}
            </small>
          </div>
        </div>
      </div>
    `
  }

  resetButton() {
    this.isGenerating = false
    this.updateButtonState(false)
    this.showProgress(false)
  }
}