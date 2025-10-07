import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-preview"
export default class extends Controller {
  static targets = ["container", "previews"]

  connect() {
    this.setupFileInput()
  }

  setupFileInput() {
    this.element.addEventListener('change', (e) => {
      this.handleFileSelection(e.target.files)
    })
  }

  handleFileSelection(files) {
    if (files.length === 0) {
      this.hidePreview()
      return
    }

    this.showPreview()
    this.clearPreviews()
    
    Array.from(files).forEach((file, index) => {
      if (this.isValidImageFile(file)) {
        this.createImagePreview(file, index)
      } else {
        this.showFileError(file.name)
      }
    })
  }

  isValidImageFile(file) {
    const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/svg+xml']
    const maxSize = 5 * 1024 * 1024 // 5MB
    
    return validTypes.includes(file.type) && file.size <= maxSize
  }

  createImagePreview(file, index) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      const previewElement = this.createPreviewElement(file, e.target.result, index)
      this.previewsTarget.appendChild(previewElement)
    }
    
    reader.readAsDataURL(file)
  }

  createPreviewElement(file, dataUrl, index) {
    const col = document.createElement('div')
    col.className = 'col-md-3'
    
    col.innerHTML = `
      <div class="position-relative">
        <img src="${dataUrl}" class="img-thumbnail w-100" style="height: 120px; object-fit: cover;" alt="Preview ${index + 1}">
        <div class="position-absolute top-0 end-0 m-1">
          <button type="button" class="btn btn-sm btn-danger" data-action="click->file-preview#removePreview" data-index="${index}">
            <i class="bi bi-x"></i>
          </button>
        </div>
        <div class="position-absolute bottom-0 start-0 end-0 bg-dark bg-opacity-75 text-white p-1">
          <small>${file.name}</small>
        </div>
      </div>
    `
    
    return col
  }

  showFileError(fileName) {
    const errorElement = document.createElement('div')
    errorElement.className = 'col-12'
    errorElement.innerHTML = `
      <div class="alert alert-warning alert-sm">
        <i class="bi bi-exclamation-triangle me-2"></i>
        ${fileName} is not a valid image file or is too large (max 5MB)
      </div>
    `
    this.previewsTarget.appendChild(errorElement)
  }

  removePreview(event) {
    const index = parseInt(event.target.dataset.index)
    const previewElement = event.target.closest('.col-md-3')
    
    if (previewElement) {
      previewElement.remove()
    }
    
    // Update the file input to remove the file
    this.updateFileInput(index)
  }

  updateFileInput(removeIndex) {
    const fileInput = this.element
    const dt = new DataTransfer()
    
    Array.from(fileInput.files).forEach((file, index) => {
      if (index !== removeIndex) {
        dt.items.add(file)
      }
    })
    
    fileInput.files = dt.files
    
    // Hide preview if no files left
    if (fileInput.files.length === 0) {
      this.hidePreview()
    }
  }

  showPreview() {
    this.containerTarget.style.display = 'block'
  }

  hidePreview() {
    this.containerTarget.style.display = 'none'
  }

  clearPreviews() {
    this.previewsTarget.innerHTML = ''
  }
}
