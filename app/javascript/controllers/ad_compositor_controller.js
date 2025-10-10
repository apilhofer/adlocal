import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas", "elementSelector", "fontSizeSlider", "fontSizeValue", 
    "textColorPicker", "textColorValue", "ctaBgColorControl", "ctaBgColorPicker", 
    "ctaBgColorValue", "positionX", "positionY", "savePositionsBtn", 
    "resetPositionsBtn", "statusMessages"
  ]
  
  static values = { 
    generatedAdId: Number,
    adSize: String,
    backgroundUrl: String,
    elementPositions: Object
  }

  connect() {
    console.log("Ad compositor controller connected")
    this.currentElement = "headline"
    this.elementPositions = { ...this.elementPositionsValue }
    this.setupCanvas()
    this.setupEventListeners()
    this.updateControls()
  }

  setupCanvas() {
    const canvas = this.canvasTarget
    const [width, height] = this.adSizeValue.split('x').map(Number)
    
    // Set canvas dimensions
    canvas.style.width = `${Math.min(width, 400)}px`
    canvas.style.height = `${Math.min(height, 300)}px`
    canvas.style.backgroundImage = `url(${this.backgroundUrlValue})`
    canvas.style.backgroundSize = 'cover'
    canvas.style.backgroundPosition = 'center'
    
    // Create draggable elements
    this.createDraggableElements()
  }

  createDraggableElements() {
    const canvas = this.canvasTarget
    canvas.innerHTML = '' // Clear existing elements
    
    // Create logo element
    if (this.elementPositions.logo) {
      const logoEl = this.createElement('logo', this.elementPositions.logo)
      canvas.appendChild(logoEl)
    }
    
    // Create headline element
    if (this.elementPositions.headline) {
      const headlineEl = this.createElement('headline', this.elementPositions.headline)
      canvas.appendChild(headlineEl)
    }
    
    // Create subheadline element
    if (this.elementPositions.subheadline) {
      const subheadlineEl = this.createElement('subheadline', this.elementPositions.subheadline)
      canvas.appendChild(subheadlineEl)
    }
    
    // Create CTA element
    if (this.elementPositions.cta) {
      const ctaEl = this.createElement('cta', this.elementPositions.cta)
      canvas.appendChild(ctaEl)
    }
  }

  createElement(type, position) {
    const element = document.createElement('div')
    element.className = `draggable-element element-${type}`
    element.dataset.elementType = type
    
    // Set position and styling
    element.style.position = 'absolute'
    element.style.left = `${position.x}px`
    element.style.top = `${position.y}px`
    element.style.cursor = 'move'
    element.style.userSelect = 'none'
    
    if (type === 'logo') {
      element.style.width = `${position.width}px`
      element.style.height = `${position.height}px`
      element.style.backgroundColor = '#f0f0f0'
      element.style.border = '2px dashed #ccc'
      element.style.display = 'flex'
      element.style.alignItems = 'center'
      element.style.justifyContent = 'center'
      element.innerHTML = '<i class="bi bi-image"></i> Logo'
    } else if (type === 'cta') {
      element.style.width = `${position.width}px`
      element.style.height = `${position.height}px`
      element.style.backgroundColor = position.bgColor || '#ff0000'
      element.style.color = position.color || '#ffffff'
      element.style.fontSize = `${position.fontSize}px`
      element.style.display = 'flex'
      element.style.alignItems = 'center'
      element.style.justifyContent = 'center'
      element.style.borderRadius = '4px'
      element.style.fontWeight = 'bold'
      element.textContent = 'Call to Action'
    } else {
      element.style.fontSize = `${position.fontSize}px`
      element.style.color = position.color || '#000000'
      element.style.fontWeight = 'bold'
      element.style.textAlign = position.align || 'center'
      element.style.whiteSpace = 'nowrap'
      
      if (type === 'headline') {
        element.textContent = 'Sample Headline'
      } else if (type === 'subheadline') {
        element.textContent = 'Sample Subheadline'
      }
    }
    
    // Make draggable
    this.makeDraggable(element)
    
    // Add click handler for selection
    element.addEventListener('click', (e) => {
      e.stopPropagation()
      this.selectElement(type)
    })
    
    return element
  }

  makeDraggable(element) {
    let isDragging = false
    let startX, startY, startLeft, startTop
    
    element.addEventListener('mousedown', (e) => {
      isDragging = true
      startX = e.clientX
      startY = e.clientY
      startLeft = parseInt(element.style.left) || 0
      startTop = parseInt(element.style.top) || 0
      
      element.style.zIndex = '1000'
      document.addEventListener('mousemove', handleMouseMove)
      document.addEventListener('mouseup', handleMouseUp)
    })
    
    const handleMouseMove = (e) => {
      if (!isDragging) return
      
      const deltaX = e.clientX - startX
      const deltaY = e.clientY - startY
      
      const newLeft = Math.max(0, Math.min(startLeft + deltaX, 400 - element.offsetWidth))
      const newTop = Math.max(0, Math.min(startTop + deltaY, 300 - element.offsetHeight))
      
      element.style.left = `${newLeft}px`
      element.style.top = `${newTop}px`
      
      // Update position in data
      const elementType = element.dataset.elementType
      this.elementPositions[elementType].x = newLeft
      this.elementPositions[elementType].y = newTop
      
      // Update controls
      this.updatePositionControls(elementType)
    }
    
    const handleMouseUp = () => {
      isDragging = false
      element.style.zIndex = '1'
      document.removeEventListener('mousemove', handleMouseMove)
      document.removeEventListener('mouseup', handleMouseUp)
    }
  }

  setupEventListeners() {
    // Element selector change
    this.elementSelectorTarget.addEventListener('change', (e) => {
      this.selectElement(e.target.value)
    })
    
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
    
    // Position inputs
    this.positionXTarget.addEventListener('input', (e) => {
      this.updateElementPosition('x', parseInt(e.target.value) || 0)
    })
    
    this.positionYTarget.addEventListener('input', (e) => {
      this.updateElementPosition('y', parseInt(e.target.value) || 0)
    })
    
    // Alignment radio buttons
    document.querySelectorAll('input[name="alignment"]').forEach(radio => {
      radio.addEventListener('change', (e) => {
        this.updateTextAlignment(e.target.value)
      })
    })
  }

  selectElement(elementType) {
    this.currentElement = elementType
    this.elementSelectorTarget.value = elementType
    this.updateControls()
    
    // Highlight selected element
    document.querySelectorAll('.draggable-element').forEach(el => {
      el.style.border = '2px dashed #ccc'
    })
    
    const selectedEl = document.querySelector(`.element-${elementType}`)
    if (selectedEl) {
      selectedEl.style.border = '2px solid #007bff'
    }
  }

  updateControls() {
    const position = this.elementPositions[this.currentElement]
    if (!position) return
    
    // Update font size controls
    if (position.fontSize) {
      this.fontSizeSliderTarget.value = position.fontSize
      this.fontSizeValueTarget.textContent = `${position.fontSize}px`
    }
    
    // Update color controls
    if (position.color) {
      this.textColorPickerTarget.value = position.color
      this.textColorValueTarget.textContent = position.color
    }
    
    // Update CTA background color
    if (this.currentElement === 'cta' && position.bgColor) {
      this.ctaBgColorControlTarget.style.display = 'block'
      this.ctaBgColorPickerTarget.value = position.bgColor
      this.ctaBgColorValueTarget.textContent = position.bgColor
    } else {
      this.ctaBgColorControlTarget.style.display = 'none'
    }
    
    // Update position controls
    this.positionXTarget.value = position.x || 0
    this.positionYTarget.value = position.y || 0
    
    // Update alignment
    const alignment = position.align || 'center'
    document.querySelector(`input[name="alignment"][value="${alignment}"]`).checked = true
  }

  updateFontSize(size) {
    this.elementPositions[this.currentElement].fontSize = size
    this.fontSizeValueTarget.textContent = `${size}px`
    this.updateElementDisplay()
  }

  updateTextColor(color) {
    this.elementPositions[this.currentElement].color = color
    this.textColorValueTarget.textContent = color
    this.updateElementDisplay()
  }

  updateCtaBgColor(color) {
    this.elementPositions[this.currentElement].bgColor = color
    this.ctaBgColorValueTarget.textContent = color
    this.updateElementDisplay()
  }

  updateTextAlignment(alignment) {
    this.elementPositions[this.currentElement].align = alignment
    this.updateElementDisplay()
  }

  updateElementPosition(axis, value) {
    this.elementPositions[this.currentElement][axis] = value
    this.updateElementDisplay()
  }

  updateElementDisplay() {
    const element = document.querySelector(`.element-${this.currentElement}`)
    if (!element) return
    
    const position = this.elementPositions[this.currentElement]
    
    element.style.left = `${position.x}px`
    element.style.top = `${position.y}px`
    
    if (position.fontSize) {
      element.style.fontSize = `${position.fontSize}px`
    }
    
    if (position.color) {
      element.style.color = position.color
    }
    
    if (position.align) {
      element.style.textAlign = position.align
    }
    
    if (this.currentElement === 'cta' && position.bgColor) {
      element.style.backgroundColor = position.bgColor
    }
  }

  updatePositionControls(elementType) {
    if (this.currentElement === elementType) {
      const position = this.elementPositions[elementType]
      this.positionXTarget.value = position.x || 0
      this.positionYTarget.value = position.y || 0
    }
  }

  savePositions() {
    this.savePositionsBtnTarget.disabled = true
    this.savePositionsBtnTarget.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Saving...'
    
    fetch(`/generated_ads/${this.generatedAdIdValue}/update_positions`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        element_positions: this.elementPositions
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showStatus('Positions saved successfully!', 'success')
      } else {
        this.showStatus('Failed to save positions: ' + data.errors.join(', '), 'danger')
      }
    })
    .catch(error => {
      this.showStatus('Error saving positions: ' + error.message, 'danger')
    })
    .finally(() => {
      this.savePositionsBtnTarget.disabled = false
      this.savePositionsBtnTarget.innerHTML = '<i class="bi bi-save me-2"></i>Save Positions'
    })
  }

  resetPositions() {
    if (confirm('Are you sure you want to reset all positions to defaults?')) {
      // Get default positions from the server or use hardcoded defaults
      this.elementPositions = {
        logo: { x: 10, y: 10, width: 60, height: 60 },
        headline: { x: 150, y: 80, fontSize: 20, color: '#000000', align: 'center' },
        subheadline: { x: 150, y: 120, fontSize: 14, color: '#333333', align: 'center' },
        cta: { x: 75, y: 200, width: 150, height: 40, fontSize: 16, color: '#ffffff', bgColor: '#ff0000' }
      }
      
      this.createDraggableElements()
      this.updateControls()
      this.showStatus('Positions reset to defaults', 'info')
    }
  }

  showStatus(message, type) {
    const statusDiv = document.createElement('div')
    statusDiv.className = `alert alert-${type} alert-dismissible fade show`
    statusDiv.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `
    
    this.statusMessagesTarget.innerHTML = ''
    this.statusMessagesTarget.appendChild(statusDiv)
    
    // Auto-dismiss after 3 seconds
    setTimeout(() => {
      if (statusDiv.parentNode) {
        statusDiv.remove()
      }
    }, 3000)
  }
}
