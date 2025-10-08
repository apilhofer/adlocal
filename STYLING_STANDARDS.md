# AdLocal UI Styling Standards

## Overview
This document defines the standardized styling patterns for all UI elements across the AdLocal application. All styling follows Bootstrap 5 conventions with Flowbite components and maintains consistency with the AdLocal brand.

## Color Scheme
- **Primary**: `#dc3545` (Bootstrap red) - Primary actions, brand elements
- **Secondary**: `#6c757d` (Bootstrap gray) - Secondary actions, muted text
- **Success**: `#198754` (Bootstrap green) - Success states, positive actions
- **Info**: `#0dcaf0` (Bootstrap cyan) - Information, neutral actions
- **Warning**: `#ffc107` (Bootstrap yellow) - Warnings, incomplete states
- **Danger**: `#dc3545` (Bootstrap red) - Errors, destructive actions
- **Light**: `#f8f9fa` (Bootstrap light) - Backgrounds, subtle elements
- **Dark**: `#212529` (Bootstrap dark) - Text, headers, dark backgrounds

## Typography
- **Headings**: `fw-bold` for all headings (h1-h6)
- **Body text**: Default Bootstrap text classes
- **Muted text**: `text-muted` for secondary information
- **Small text**: `small` class for helper text, captions
- **Font weights**: `fw-bold`, `fw-semibold`, `fw-medium` (avoid `fw-light`, `fw-normal`)

## Buttons

### Primary Buttons
```erb
<!-- Standard primary button -->
<%= link_to "Action", path, class: "btn btn-primary" %>

<!-- Primary button with icon -->
<%= link_to path, class: "btn btn-primary" do %>
  <i class="bi bi-icon-name me-2"></i>
  Action Text
<% end %>
```

### Secondary Buttons
```erb
<!-- Standard secondary button -->
<%= link_to "Action", path, class: "btn btn-outline-primary" %>

<!-- Secondary button with icon -->
<%= link_to path, class: "btn btn-outline-primary" do %>
  <i class="bi bi-icon-name me-2"></i>
  Action Text
<% end %>
```

### Button Sizes
- **Large**: `btn-lg` - Hero sections, primary CTAs
- **Standard**: No size class - Default buttons
- **Small**: `btn-sm` - Cards, compact layouts, navigation
- **Extra Small**: `btn-xs` - Not recommended, use `btn-sm` instead

### Special Button Types
```erb
<!-- Generate Ads button (AI functionality) -->
<%= link_to path, class: "btn btn-outline-primary btn-lg" do %>
  <i class="bi bi-magic me-2"></i>
  Generate Ads
<% end %>

<!-- Danger/Delete buttons -->
<%= link_to "Delete", path, class: "btn btn-outline-danger btn-sm",
    data: { confirm: "Are you sure?" } %>

<!-- Success buttons -->
<%= link_to "Complete", path, class: "btn btn-success" %>
```

### Button States
- **Active**: `active` class for current page/state
- **Disabled**: `disabled` attribute (not class)
- **Loading**: Add spinner icon with `spinner-border spinner-border-sm me-2`

## Forms

### Form Structure
```erb
<div class="mb-3">
  <label for="field_id" class="form-label fw-bold">
    Field Label <span class="text-danger">*</span>
  </label>
  <%= f.text_field :field_name,
      id: "field_id",
      class: "form-control #{'is-invalid' if @object.errors[:field_name].any?}",
      placeholder: "Placeholder text",
      required: true %>
  <% if @object.errors[:field_name].any? %>
    <div class="invalid-feedback"><%= @object.errors[:field_name].first %></div>
  <% end %>
</div>
```

### Form Elements
- **Labels**: Always use `form-label fw-bold` with proper `for` attributes
- **Required fields**: Add `<span class="text-danger">*</span>` after label text
- **Inputs**: Use `form-control` with validation classes
- **Validation**: Use `is-invalid` class and `invalid-feedback` divs
- **Placeholders**: Use descriptive, helpful placeholder text
- **Help text**: Use `text-muted small` for helper text

### Form Layout
```erb
<!-- Single column -->
<div class="col-12 mb-3">
  <!-- Form field -->
</div>

<!-- Two columns -->
<div class="col-md-6 mb-3">
  <!-- Form field -->
</div>

<!-- Three columns -->
<div class="col-md-4 mb-3">
  <!-- Form field -->
</div>
```

### Special Form Elements
```erb
<!-- Textarea -->
<%= f.text_area :field_name,
    id: "field_id",
    rows: 4,
    class: "form-control #{'is-invalid' if @object.errors[:field_name].any?}",
    placeholder: "Enter detailed information..." %>

<!-- Select dropdown -->
<%= f.select :field_name,
    options_for_select([['Option 1', 'value1'], ['Option 2', 'value2']]),
    { prompt: 'Select an option' },
    { 
      id: "field_id",
      class: "form-control #{'is-invalid' if @object.errors[:field_name].any?}",
      required: true 
    } %>

<!-- File upload -->
<%= f.file_field :field_name,
    id: "field_id",
    class: "form-control #{'is-invalid' if @object.errors[:field_name].any?}",
    accept: "image/*" %>

<!-- Checkbox -->
<div class="form-check">
  <%= f.check_box :field_name,
      id: "field_id",
      class: "form-check-input #{'is-invalid' if @object.errors[:field_name].any?}" %>
  <label for="field_id" class="form-check-label fw-bold">
    Checkbox Label
  </label>
</div>
```

## Cards

### Standard Card Structure
```erb
<div class="card mb-4 border-0 shadow-sm">
  <div class="card-header bg-white border-bottom">
    <h5 class="mb-0 fw-bold text-dark">
      <i class="bi bi-icon-name text-primary me-2"></i>
      Card Title
    </h5>
  </div>
  <div class="card-body">
    <!-- Card content -->
  </div>
</div>
```

### Card Variations
```erb
<!-- Card with no header -->
<div class="card mb-4 border-0 shadow-sm">
  <div class="card-body">
    <!-- Content -->
  </div>
</div>

<!-- Card with footer -->
<div class="card mb-4 border-0 shadow-sm">
  <div class="card-body">
    <!-- Content -->
  </div>
  <div class="card-footer bg-white border-top">
    <!-- Footer content -->
  </div>
</div>

<!-- Card with image -->
<div class="card mb-4 border-0 shadow-sm">
  <div class="card-img-top">
    <!-- Image content -->
  </div>
  <div class="card-body">
    <!-- Content -->
  </div>
</div>
```

## Navigation

### Navbar
```erb
<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top">
  <div class="container">
    <!-- Logo and navigation content -->
  </div>
</nav>
```

### Navigation Links
```erb
<!-- Standard nav link -->
<a class="nav-link" href="#">Link Text</a>

<!-- Active nav link -->
<a class="nav-link active" href="#">Current Page</a>
```

### Dropdowns
```erb
<div class="dropdown">
  <button class="btn btn-outline-primary dropdown-toggle" type="button" 
          data-bs-toggle="dropdown" aria-expanded="false">
    Dropdown Label
  </button>
  <ul class="dropdown-menu">
    <li><a class="dropdown-item" href="#">Action 1</a></li>
    <li><a class="dropdown-item" href="#">Action 2</a></li>
    <li><hr class="dropdown-divider"></li>
    <li><a class="dropdown-item" href="#">Separated Action</a></li>
  </ul>
</div>
```

## Status Indicators

### Badges
```erb
<!-- Status badges -->
<span class="badge bg-primary">Primary</span>
<span class="badge bg-success">Success</span>
<span class="badge bg-warning">Warning</span>
<span class="badge bg-danger">Danger</span>
<span class="badge bg-info">Info</span>
<span class="badge bg-secondary">Secondary</span>

<!-- Large badges -->
<span class="badge bg-primary px-3 py-2 fs-6">Large Badge</span>
```

### Progress Indicators
```erb
<!-- Progress bar -->
<div class="progress mb-3">
  <div class="progress-bar" role="progressbar" style="width: 75%"></div>
</div>

<!-- Completion percentage -->
<span class="badge bg-success"><%= percentage %>%</span>
```

## Alerts and Messages

### Flash Messages
```erb
<!-- Success -->
<div class="alert alert-success alert-dismissible fade show" role="alert">
  <i class="bi bi-check-circle me-2"></i>
  Success message
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>

<!-- Error -->
<div class="alert alert-danger alert-dismissible fade show" role="alert">
  <i class="bi bi-exclamation-triangle me-2"></i>
  Error message
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>

<!-- Info -->
<div class="alert alert-info" role="alert">
  <i class="bi bi-info-circle me-2"></i>
  Information message
</div>
```

## Icons

### Bootstrap Icons Usage
- **Standard size**: No size class (16px)
- **Small**: `small` class (14px)
- **Large**: `fs-4` or `fs-5` classes
- **Spacing**: Always use `me-2` or `me-1` for margin

### Common Icons
```erb
<!-- Navigation -->
<i class="bi bi-house"></i>
<i class="bi bi-person"></i>
<i class="bi bi-gear"></i>

<!-- Actions -->
<i class="bi bi-plus"></i>
<i class="bi bi-pencil"></i>
<i class="bi bi-trash"></i>
<i class="bi bi-eye"></i>

<!-- Status -->
<i class="bi bi-check-circle"></i>
<i class="bi bi-exclamation-triangle"></i>
<i class="bi bi-info-circle"></i>

<!-- Special -->
<i class="bi bi-magic"></i> <!-- For AI/Generate Ads -->
<i class="bi bi-calendar3"></i>
<i class="bi bi-image"></i>
```

## Layout and Spacing

### Containers
```erb
<!-- Standard page container -->
<div class="container py-5">
  <!-- Page content -->
</div>

<!-- Full-width sections -->
<section class="bg-light py-5">
  <div class="container">
    <!-- Section content -->
  </div>
</section>
```

### Grid System
```erb
<!-- Standard row -->
<div class="row g-4">
  <div class="col-md-6 col-lg-4">
    <!-- Content -->
  </div>
</div>

<!-- Flex layouts -->
<div class="d-flex flex-column flex-sm-row gap-3 justify-content-center">
  <!-- Flex content -->
</div>
```

### Spacing
- **Cards**: `mb-4` between cards
- **Form fields**: `mb-3` between form fields
- **Sections**: `py-5` for section padding
- **Buttons**: `gap-2` or `gap-3` for button groups

## Responsive Design

### Breakpoints
- **Mobile**: Default (no prefix)
- **Tablet**: `md:` prefix
- **Desktop**: `lg:` prefix
- **Large Desktop**: `xl:` prefix

### Responsive Patterns
```erb
<!-- Responsive columns -->
<div class="col-12 col-md-6 col-lg-4">

<!-- Responsive buttons -->
<div class="d-flex flex-column flex-sm-row gap-3">

<!-- Responsive text -->
<h1 class="display-4 display-lg-1 fw-bold">
```

## Accessibility

### Required Attributes
- **Labels**: Always use `for` attribute matching input `id`
- **Buttons**: Include `aria-label` for icon-only buttons
- **Forms**: Use `required` attribute for required fields
- **Alerts**: Include `role="alert"` for dynamic messages

### Focus States
- All interactive elements must have visible focus indicators
- Use Bootstrap's default focus styles
- Test with keyboard navigation

## Implementation Guidelines

### Do's
- ✅ Use Bootstrap classes consistently
- ✅ Follow the established color scheme
- ✅ Include proper validation styling
- ✅ Use semantic HTML elements
- ✅ Maintain responsive design
- ✅ Include proper accessibility attributes

### Don'ts
- ❌ Mix different button styles inconsistently
- ❌ Use custom CSS when Bootstrap classes exist
- ❌ Skip validation styling
- ❌ Use inline styles (except for specific cases)
- ❌ Ignore responsive design
- ❌ Skip accessibility attributes

## Examples

### Complete Form Example
```erb
<div class="card mb-4 border-0 shadow-sm">
  <div class="card-header bg-white border-bottom">
    <h5 class="mb-0 fw-bold text-dark">
      <i class="bi bi-info-circle text-primary me-2"></i>
      Form Title
    </h5>
  </div>
  <div class="card-body">
    <div class="row">
      <div class="col-md-6 mb-3">
        <label for="field_name" class="form-label fw-bold">
          Field Label <span class="text-danger">*</span>
        </label>
        <%= f.text_field :field_name,
            id: "field_name",
            class: "form-control #{'is-invalid' if @object.errors[:field_name].any?}",
            placeholder: "Enter value",
            required: true %>
        <% if @object.errors[:field_name].any? %>
          <div class="invalid-feedback"><%= @object.errors[:field_name].first %></div>
        <% end %>
      </div>
    </div>
    <div class="d-flex justify-content-end gap-2">
      <%= link_to "Cancel", back_path, class: "btn btn-outline-secondary" %>
      <%= f.submit "Save", class: "btn btn-primary" %>
    </div>
  </div>
</div>
```

### Complete Button Group Example
```erb
<div class="d-flex gap-2">
  <%= link_to "View", object_path, class: "btn btn-outline-primary btn-sm flex-fill" %>
  <%= link_to "Edit", edit_object_path, class: "btn btn-outline-secondary btn-sm flex-fill" %>
  <%= link_to path, class: "btn btn-outline-primary btn-sm flex-fill" do %>
    <i class="bi bi-magic me-1"></i>
    Generate Ads
  <% end %>
</div>
```

---

*This document should be updated whenever new UI patterns are established or existing patterns are modified.*
