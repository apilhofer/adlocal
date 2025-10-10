import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas", "logoElement", "headlineElement", "subheadlineElement", "ctaElement",
    "editLogoBtn", "editHeadlineBtn", "editSubheadlineBtn", "editCtaBtn",
    "fontSizeSlider", "fontSizeValue", "textColorPicker", "textColorValue",
    "ctaBgColorControl", "ctaBgColorPicker", "ctaBgColorValue",
    "savePositionsBtn", "renderAdsBtn"
  ]
  
  static values = { campaignId: Number }

  connect() {
    console.log("Inline ad editor controller connected")
    this.currentElement = null
    this.currentAdId = null
    this.setupEventListeners()
    this.initializeElements()
    this.setupBackgroundUpdateListener()
  }

  setupBackgroundUpdateListener() {
    // Listen for background regeneration events
    document.addEventListener('backgroundRegenerated', (event) => {
      console.log('🎨 Background regenerated event received:', event.detail)
      console.log('🎨 Updating ad canvases...')
      this.updateCanvasBackgrounds()
    })
  }

  updateCanvasBackgrounds() {
    console.log('🎨 updateCanvasBackgrounds called')
    console.log('🎨 Canvas targets found:', this.canvasTargets.length)
    
    // Fetch updated background variants from the server
    fetch(`/campaigns/${this.campaignIdValue}/background_variants.json`)
      .then(response => response.json())
      .then(variants => {
        console.log('🎨 Received background variants:', variants)
        
        // Update each canvas with the appropriate background
        this.canvasTargets.forEach(canvas => {
          const adSize = canvas.dataset.adSize
          console.log(`🎨 Processing canvas for ad size: ${adSize}`)
          const backgroundVariant = this.getBackgroundVariantForAdSize(variants, adSize)
          
          if (backgroundVariant) {
            const backgroundUrl = backgroundVariant.image_url
            console.log(`🎨 Updating canvas for ${adSize} with background:`, backgroundUrl)
            
            // Update the background image
            canvas.style.backgroundImage = `url('${backgroundUrl}')`
            canvas.dataset.backgroundUrl = backgroundUrl
            
            // Add a subtle animation to show the update
            canvas.style.transition = 'opacity 0.3s ease'
            canvas.style.opacity = '0.7'
            setTimeout(() => {
              canvas.style.opacity = '1'
              canvas.style.transition = ''
            }, 300)
          } else {
            console.log(`🎨 No background variant found for ad size: ${adSize}`)
          }
        })
      })
      .catch(error => {
        console.error('🎨 Error fetching background variants:', error)
      })
  }

  getBackgroundVariantForAdSize(variants, adSize) {
    // Map ad sizes to background variants
    switch (adSize) {
      case '728x90':
      case '320x50':
      case '970x250':  // Billboard - wide format
        return variants.find(v => v.aspect === 'leaderboard')
      case '160x600':
      case '300x600':
        return variants.find(v => v.aspect === 'skyscraper')
      case '300x250':
      case '336x280':  // Large Rectangle - square-ish format
      case '1080x1080':  // Square / Social - perfect square
      default:
        return variants.find(v => v.aspect === 'square')
    }
  }

  initializeElements() {
    // Initialize all canvas elements with their positions
    this.canvasTargets.forEach(canvas => {
      const adId = canvas.dataset.adId
      const positions = JSON.parse(canvas.dataset.elementPositions)
      
      // Set initial positions for all elements
      this.setElementPositions(canvas, positions)
    })
  }

  setElementPositions(canvas, positions) {
    // Logo
    const logoEl = canvas.querySelector('.element-logo')
    if (logoEl && positions.logo) {
      logoEl.style.left = `${positions.logo.x}px`
      logoEl.style.top = `${positions.logo.y}px`
      logoEl.style.width = `${positions.logo.width}px`
      logoEl.style.height = `${positions.logo.height}px`
    }
    
    // Headline
    const headlineEl = canvas.querySelector('.element-headline')
    if (headlineEl && positions.headline) {
      headlineEl.style.left = `${positions.headline.x}px`
      headlineEl.style.top = `${positions.headline.y}px`
      headlineEl.style.fontSize = `${positions.headline.fontSize}px`
      headlineEl.style.color = positions.headline.color
      headlineEl.style.textAlign = positions.headline.align
    }
    
    // Subheadline
    const subheadlineEl = canvas.querySelector('.element-subheadline')
    if (subheadlineEl && positions.subheadline) {
      subheadlineEl.style.left = `${positions.subheadline.x}px`
      subheadlineEl.style.top = `${positions.subheadline.y}px`
      subheadlineEl.style.fontSize = `${positions.subheadline.fontSize}px`
      subheadlineEl.style.color = positions.subheadline.color
      subheadlineEl.style.textAlign = positions.subheadline.align
    }
    
    // CTA
    const ctaEl = canvas.querySelector('.element-cta')
    if (ctaEl && positions.cta) {
      ctaEl.style.left = `${positions.cta.x}px`
      ctaEl.style.top = `${positions.cta.y}px`
      ctaEl.style.width = `${positions.cta.width}px`
      ctaEl.style.height = `${positions.cta.height}px`
      ctaEl.style.fontSize = `${positions.cta.fontSize}px`
      ctaEl.style.color = positions.cta.color
      ctaEl.style.backgroundColor = positions.cta.bgColor
    }
  }

  setupEventListeners() {
    // Font size slider
    this.fontSizeSliderTarget.addEventListener('input', (e) => {
      this.updateFontSize(parseInt(e.target.value))
    })
    
    // Text color picker
    this.textColorPickerTarget.addEventListener('change', (e) => {
      this.updateTextColor(e.target.value)
    })
    
    // CTA background color picker
    this.ctaBgColorPickerTarget.addEventListener('change', (e) => {
      this.updateCtaBgColor(e.target.value)
    })
    
    // Alignment radio buttons
    document.querySelectorAll('input[name="alignment"]').forEach(radio => {
      radio.addEventListener('change', (e) => {
        this.updateTextAlignment(e.target.value)
      })
    })
    
    // Make all elements draggable
    this.makeAllElementsDraggable()
  }

  makeAllElementsDraggable() {
    this.canvasTargets.forEach(canvas => {
      const elements = canvas.querySelectorAll('.draggable-element')
      elements.forEach(element => {
        this.makeDraggable(element, canvas)
      })
    })
  }

  makeDraggable(element, canvas) {
    let isDragging = false
    let startX, startY, startLeft, startTop
    
    element.addEventListener('mousedown', (e) => {
      e.preventDefault()
      isDragging = true
      startX = e.clientX
      startY = e.clientY
      startLeft = parseInt(element.style.left) || 0
      startTop = parseInt(element.style.top) || 0
      
      element.style.zIndex = '1000'
      element.style.border = '2px solid #007bff'
      
      document.addEventListener('mousemove', handleMouseMove)
      document.addEventListener('mouseup', handleMouseUp)
    })
    
    const handleMouseMove = (e) => {
      if (!isDragging) return
      
      const deltaX = e.clientX - startX
      const deltaY = e.clientY - startY
      
      const canvasRect = canvas.getBoundingClientRect()
      const maxX = canvasRect.width - element.offsetWidth
      const maxY = canvasRect.height - element.offsetHeight
      
      const newLeft = Math.max(0, Math.min(startLeft + deltaX, maxX))
      const newTop = Math.max(0, Math.min(startTop + deltaY, maxY))
      
      element.style.left = `${newLeft}px`
      element.style.top = `${newTop}px`
    }
    
    const handleMouseUp = () => {
      isDragging = false
      element.style.zIndex = '1'
      element.style.border = element.classList.contains('element-logo') ? '2px dashed #007bff' : 'none'
      document.removeEventListener('mousemove', handleMouseMove)
      document.removeEventListener('mouseup', handleMouseUp)
    }
  }

  selectElement(event) {
    const elementType = event.target.dataset.elementType
    this.currentElement = elementType
    
    // Highlight selected element type across all canvases
    this.canvasTargets.forEach(canvas => {
      const elements = canvas.querySelectorAll('.draggable-element')
      elements.forEach(el => {
        el.style.border = el.dataset.elementType === elementType ? '2px solid #007bff' : 'none'
        if (el.classList.contains('element-logo')) {
          el.style.border = el.dataset.elementType === elementType ? '2px solid #007bff' : '2px dashed #007bff'
        }
      })
    })
    
    // Update controls based on selected element
    this.updateControlsForElement(elementType)
  }

  updateControlsForElement(elementType) {
    // Find the first canvas to get current values
    const firstCanvas = this.canvasTargets[0]
    if (!firstCanvas) return
    
    const positions = JSON.parse(firstCanvas.dataset.elementPositions)
    const elementPos = positions[elementType]
    
    if (!elementPos) return
    
    // Update font size controls
    if (elementPos.fontSize) {
      this.fontSizeSliderTarget.value = elementPos.fontSize
      this.fontSizeValueTarget.textContent = `${elementPos.fontSize}px`
    }
    
    // Update color controls
    if (elementPos.color) {
      this.textColorPickerTarget.value = elementPos.color
      this.textColorValueTarget.textContent = elementPos.color
    }
    
    // Update CTA background color
    if (elementType === 'cta' && elementPos.bgColor) {
      this.ctaBgColorControlTarget.style.display = 'block'
      this.ctaBgColorPickerTarget.value = elementPos.bgColor
      this.ctaBgColorValueTarget.textContent = elementPos.bgColor
    } else {
      this.ctaBgColorControlTarget.style.display = 'none'
    }
    
    // Update alignment
    const alignment = elementPos.align || 'center'
    document.querySelector(`input[name="alignment"][value="${alignment}"]`).checked = true
  }

  updateFontSize(size) {
    if (!this.currentElement) return
    
    this.fontSizeValueTarget.textContent = `${size}px`
    
    // Update all elements of this type across all canvases
    this.canvasTargets.forEach(canvas => {
      const element = canvas.querySelector(`.element-${this.currentElement}`)
      if (element) {
        element.style.fontSize = `${size}px`
      }
    })
  }

  updateTextColor(color) {
    if (!this.currentElement) return
    
    this.textColorValueTarget.textContent = color
    
    // Update all elements of this type across all canvases
    this.canvasTargets.forEach(canvas => {
      const element = canvas.querySelector(`.element-${this.currentElement}`)
      if (element) {
        element.style.color = color
      }
    })
  }

  updateCtaBgColor(color) {
    if (this.currentElement !== 'cta') return
    
    this.ctaBgColorValueTarget.textContent = color
    
    // Update all CTA elements across all canvases
    this.canvasTargets.forEach(canvas => {
      const element = canvas.querySelector('.element-cta')
      if (element) {
        element.style.backgroundColor = color
      }
    })
  }

  updateTextAlignment(alignment) {
    if (!this.currentElement) return
    
    // Update all elements of this type across all canvases
    this.canvasTargets.forEach(canvas => {
      const element = canvas.querySelector(`.element-${this.currentElement}`)
      if (element) {
        element.style.textAlign = alignment
      }
    })
  }

  saveAllPositions() {
    this.savePositionsBtnTarget.disabled = true
    this.savePositionsBtnTarget.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Saving...'
    
    const updates = []
    
    this.canvasTargets.forEach(canvas => {
      const adId = canvas.dataset.adId
      const positions = this.getElementPositions(canvas)
      
      updates.push({
        ad_id: adId,
        element_positions: positions
      })
    })
    
    // Send all updates
    fetch(`/campaigns/${this.campaignIdValue}/update_all_ad_positions`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ updates: updates })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showStatus('All positions saved successfully!', 'success')
      } else {
        this.showStatus('Failed to save positions: ' + data.errors.join(', '), 'danger')
      }
    })
    .catch(error => {
      this.showStatus('Error saving positions: ' + error.message, 'danger')
    })
    .finally(() => {
      this.savePositionsBtnTarget.disabled = false
      this.savePositionsBtnTarget.innerHTML = '<i class="bi bi-save me-2"></i>Save Changes'
    })
  }

  getElementPositions(canvas) {
    const positions = {}
    
    // Logo
    const logoEl = canvas.querySelector('.element-logo')
    if (logoEl) {
      positions.logo = {
        x: parseInt(logoEl.style.left) || 0,
        y: parseInt(logoEl.style.top) || 0,
        width: parseInt(logoEl.style.width) || 60,
        height: parseInt(logoEl.style.height) || 60
      }
    }
    
    // Headline
    const headlineEl = canvas.querySelector('.element-headline')
    if (headlineEl) {
      positions.headline = {
        x: parseInt(headlineEl.style.left) || 0,
        y: parseInt(headlineEl.style.top) || 0,
        fontSize: parseInt(headlineEl.style.fontSize) || 16,
        color: headlineEl.style.color || '#000000',
        align: headlineEl.style.textAlign || 'center'
      }
    }
    
    // Subheadline
    const subheadlineEl = canvas.querySelector('.element-subheadline')
    if (subheadlineEl) {
      positions.subheadline = {
        x: parseInt(subheadlineEl.style.left) || 0,
        y: parseInt(subheadlineEl.style.top) || 0,
        fontSize: parseInt(subheadlineEl.style.fontSize) || 14,
        color: subheadlineEl.style.color || '#333333',
        align: subheadlineEl.style.textAlign || 'center'
      }
    }
    
    // CTA
    const ctaEl = canvas.querySelector('.element-cta')
    if (ctaEl) {
      positions.cta = {
        x: parseInt(ctaEl.style.left) || 0,
        y: parseInt(ctaEl.style.top) || 0,
        width: parseInt(ctaEl.style.width) || 100,
        height: parseInt(ctaEl.style.height) || 40,
        fontSize: parseInt(ctaEl.style.fontSize) || 16,
        color: ctaEl.style.color || '#ffffff',
        bgColor: ctaEl.style.backgroundColor || '#ff0000'
      }
    }
    
    return positions
  }

  renderAllAds() {
    if (confirm('Are you sure? This will render all ads as final images and lock them for editing.')) {
      this.renderAdsBtnTarget.disabled = true
      this.renderAdsBtnTarget.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Rendering...'
      
      // First save all positions
      this.saveAllPositions()
      
      // Then render all ads
      fetch(`/campaigns/${this.campaignIdValue}/render_all_ads`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.showStatus('All ads rendered successfully!', 'success')
          // Reload page to show rendered ads
          setTimeout(() => {
            window.location.reload()
          }, 2000)
        } else {
          this.showStatus('Failed to render ads: ' + data.errors.join(', '), 'danger')
        }
      })
      .catch(error => {
        this.showStatus('Error rendering ads: ' + error.message, 'danger')
      })
      .finally(() => {
        this.renderAdsBtnTarget.disabled = false
        this.renderAdsBtnTarget.innerHTML = '<i class="bi bi-magic me-2"></i>Render Ads'
      })
    }
  }

  editAllAds() {
    if (confirm('Are you sure? This will unlock all ads for editing.')) {
      fetch(`/campaigns/${this.campaignIdValue}/unlock_all_ads`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.showStatus('All ads unlocked for editing!', 'success')
          // Reload page to show editable ads
          setTimeout(() => {
            window.location.reload()
          }, 2000)
        } else {
          this.showStatus('Failed to unlock ads: ' + data.errors.join(', '), 'danger')
        }
      })
      .catch(error => {
        this.showStatus('Error unlocking ads: ' + error.message, 'danger')
      })
    }
  }

  showStatus(message, type) {
    // Create status message
    const statusDiv = document.createElement('div')
    statusDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`
    statusDiv.style.top = '20px'
    statusDiv.style.right = '20px'
    statusDiv.style.zIndex = '9999'
    statusDiv.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `
    
    document.body.appendChild(statusDiv)
    
    // Auto-dismiss after 3 seconds
    setTimeout(() => {
      if (statusDiv.parentNode) {
        statusDiv.remove()
      }
    }, 3000)
  }
}
