import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["button", "progress", "progressBar", "status", "error", "backgroundImage", "regenerateButton"]
  static values = { campaignId: Number }

  connect() {
    console.log("Ad generation controller connected")
    this.isGenerating = false
    this.backgroundVariants = null
    
    // Initialize ActionCable subscription
    this.initializeActionCable()
  }

  initializeActionCable() {
    console.log("🔌 Initializing ActionCable...")
    console.log("🔌 createConsumer available:", typeof createConsumer !== 'undefined')
    console.log("🔌 Campaign ID:", this.campaignIdValue)
    
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
            console.log("📨 Message type:", data.type)
            console.log("📨 Message data:", JSON.stringify(data, null, 2))
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
      case "background_complete":
        console.log("🖼️ Background variants generated:", data.background_variants)
        this.backgroundVariants = data.background_variants
        this.showBackgroundVariants(data.background_variants)
        this.updateButtonToRegenerate()
        this.resetRegenerateButton()
        
        // Dispatch event to update Tab 3 canvases (for regeneration)
        // This will work for regeneration since canvases already exist
        document.dispatchEvent(new CustomEvent('backgroundRegenerated', {
          detail: { variants: data.background_variants }
        }))
        break
      case "completion":
        console.log("✅ Completion received with variants:", data.variants)
        this.updateProgress(100)
        this.updateStatus("Ad generation completed!")
        
        // Dispatch event to update Tab 3 canvases now that they exist
        // Fetch fresh background variants from the API
        fetch(`/campaigns/${this.campaignIdValue}/background_variants.json`)
          .then(response => response.json())
          .then(variants => {
            document.dispatchEvent(new CustomEvent('backgroundRegenerated', {
              detail: { variants: variants }
            }))
          })
          .catch(error => {
            console.error('Error fetching background variants for Tab 3 update:', error)
          })
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
    this.clearError()
    
    // Debug CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    console.log("🔐 CSRF Token element:", csrfToken)
    console.log("🔐 CSRF Token content:", csrfToken ? csrfToken.content : "NOT FOUND")
    
    if (!csrfToken || !csrfToken.content) {
      this.showError("CSRF token not found. Please refresh the page.")
      this.resetButton()
      return
    }
    
    fetch(`/campaigns/${this.campaignIdValue}/generate_ads`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken.content
      }
    })
    .then(response => {
      console.log("📡 Response status:", response.status)
      console.log("📡 Response headers:", response.headers)
      return response.json()
    })
    .then(data => {
      console.log("📡 Response data:", data)
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
      console.error('❌ Error:', error)
      this.showError("Failed to start ad generation: " + error.message)
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


  resetButton() {
    console.log('🔄 resetButton called')
    this.isGenerating = false
    
    // Handle dynamic button (if present)
    if (this.hasButtonTarget) {
      console.log('🔄 Showing button again in resetButton')
      this.buttonTarget.style.display = 'block' // Show the button again
      this.updateButtonState(false)
    }
    
    // Handle static regenerate button (if present)
    if (this.hasRegenerateButtonTarget) {
      this.updateRegenerateButtonState(false)
    }
    
    this.showProgress(false)
  }

  showBackgroundVariants(variants) {
    // Clear any existing content
    this.backgroundImageTarget.innerHTML = ''
    
    // Create a container for all variants
    const variantsContainer = document.createElement('div')
    variantsContainer.className = 'row g-3'
    
    variants.forEach((variant, index) => {
      // Create a card for each variant
      const variantCard = document.createElement('div')
      variantCard.className = 'col-md-4'
      
      variantCard.innerHTML = `
        <div class="card border-0 shadow-sm">
          <div class="card-header bg-white border-bottom">
            <h6 class="mb-0 fw-bold text-dark">
              <i class="bi bi-image text-primary me-2"></i>
              ${variant.aspect.charAt(0).toUpperCase() + variant.aspect.slice(1)} Background
            </h6>
          </div>
          <div class="card-body text-center">
            <img src="${variant.url}" 
                 class="img-fluid rounded mb-2" 
                 style="max-height: 200px; border: 2px solid #dee2e6;"
                 alt="${variant.aspect} background">
            <p class="text-muted small mb-0">${variant.size}</p>
          </div>
        </div>
      `
      
      variantsContainer.appendChild(variantCard)
    })
    
    // Create regenerate button container
    const buttonContainer = document.createElement('div')
    buttonContainer.className = 'text-center mt-3'
    buttonContainer.innerHTML = `
      <button data-ad-generation-target="regenerateButton" 
              data-action="click->ad-generation#regenerateImage"
              class="btn btn-outline-warning">
        <i class="bi bi-arrow-clockwise me-2"></i>
        Regenerate Images
      </button>
    `
    
    this.backgroundImageTarget.appendChild(variantsContainer)
    this.backgroundImageTarget.appendChild(buttonContainer)
    this.backgroundImageTarget.style.display = 'block'
  }


  updateButtonToRegenerate() {
    console.log('🔄 updateButtonToRegenerate called')
    console.log('🔄 hasButtonTarget:', this.hasButtonTarget)
    
    // Hide the original generate button since we now have images
    if (this.hasButtonTarget) {
      console.log('🔄 Hiding original button')
      this.buttonTarget.style.display = 'none'
    } else {
      console.log('🔄 No button target found')
    }
    
    // Handle static regenerate button (if present)
    if (this.hasRegenerateButtonTarget) {
      this.regenerateButtonTarget.innerHTML = '<i class="bi bi-arrow-clockwise me-2"></i>Regenerate Image'
      this.regenerateButtonTarget.disabled = false
      this.regenerateButtonTarget.classList.remove('btn-secondary')
      this.regenerateButtonTarget.classList.add('btn-outline-warning')
    }
  }

  updateRegenerateButtonState(isGenerating) {
    if (!this.hasRegenerateButtonTarget) return
    
    if (isGenerating) {
      this.regenerateButtonTarget.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Regenerating...'
      this.regenerateButtonTarget.disabled = true
      this.regenerateButtonTarget.classList.add('btn-secondary')
      this.regenerateButtonTarget.classList.remove('btn-outline-warning')
    } else {
      this.regenerateButtonTarget.innerHTML = '<i class="bi bi-arrow-clockwise me-2"></i>Regenerate Images'
      this.regenerateButtonTarget.disabled = false
      this.regenerateButtonTarget.classList.remove('btn-secondary')
      this.regenerateButtonTarget.classList.add('btn-outline-warning')
    }
  }

  resetRegenerateButton() {
    this.isGenerating = false
    this.updateRegenerateButtonState(false)
    this.showProgress(false)
  }

  regenerateImage(event) {
    event.preventDefault()
    
    if (this.isGenerating) return
    
    this.isGenerating = true
    this.updateRegenerateButtonState(true)
    this.showProgress(true)
    this.clearError()
    
    fetch(`/campaigns/${this.campaignIdValue}/regenerate_background`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === "started") {
        this.updateStatus("Regenerating background image...")
        this.updateProgress(10)
        // Real-time updates will come via ActionCable
      } else if (data.error) {
        this.showError(data.error)
        this.resetRegenerateButton()
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showError("Failed to regenerate background image")
      this.resetRegenerateButton()
    })
  }

  proceedToEditing(event) {
    event.preventDefault()
    
    if (!this.backgroundVariants || this.backgroundVariants.length === 0) {
      this.showError("No background images available")
      return
    }
    
    // Hide the background image section and show the inline editing interface
    this.backgroundImageTarget.style.display = 'none'
    
    // Trigger the next step in the workflow
    fetch(`/campaigns/${this.campaignIdValue}/proceed_to_editing`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Reload the page to show the inline editing interface
        window.location.reload()
      } else {
        this.showError(data.error || "Failed to proceed to editing")
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showError("Failed to proceed to editing")
    })
  }
}