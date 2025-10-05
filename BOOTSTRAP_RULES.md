# AdLocal Bootstrap 5 Application Rules

## Default Component Framework: Bootstrap 5

### 🎨 **Always Use Bootstrap Components**
- **Default Choice**: Use Bootstrap 5 components for ALL UI elements instead of custom CSS or other component libraries
- **Consistency**: Maintain consistent design patterns across the entire application
- **Responsive**: All components must be responsive and mobile-friendly

### 📝 **Form Components**
- **Input Fields**: Use Bootstrap form classes: `form-control`
- **Textareas**: Same styling as inputs: `form-control`
- **Labels**: Always use: `form-label`
- **Required Fields**: Mark with `<span class="text-danger">*</span>`
- **Error States**: Add `is-invalid` class when validation errors exist
- **File Uploads**: Use Bootstrap file input styling: `form-control`

### 🔘 **Button Components**
- **Primary Buttons**: `btn btn-primary`
- **Secondary Buttons**: `btn btn-outline-secondary`
- **Small Buttons**: `btn btn-primary btn-sm`
- **Icon Buttons**: Include proper Bootstrap icons with appropriate sizing

### 🏗️ **Layout Components**
- **Cards**: Use Bootstrap card classes: `card`, `card-header`, `card-body`
- **Grid System**: Use Bootstrap's 12-column grid: `container`, `row`, `col-*`
- **Containers**: Use `container` or `container-fluid` for main content areas
- **Sections**: Use `border-bottom` for section dividers

### 🎯 **Color Scheme**
- **Primary Red**: Bootstrap's `danger` color (`#dc3545`) for primary actions and accents
- **Hover States**: Bootstrap automatically handles hover states
- **Focus States**: Bootstrap automatically handles focus states
- **Text Colors**: Use `text-primary`, `text-muted`, `text-dark` for text hierarchy

### 📱 **Responsive Design**
- **Mobile First**: Bootstrap is mobile-first by default
- **Breakpoints**: Use `sm:`, `md:`, `lg:`, `xl:` for responsive utilities
- **Grid Columns**: `col-12 col-md-6 col-lg-4` for responsive layouts
- **Flexbox**: Use `d-flex` and related classes for flexible layouts

### 🔍 **Accessibility Requirements**
- **Labels**: Every input must have a proper `<label>` with `for` attribute
- **IDs**: All form inputs must have unique `id` attributes
- **Focus States**: Bootstrap provides accessible focus indicators
- **ARIA**: Use Bootstrap's built-in ARIA support
- **Color Contrast**: Bootstrap ensures sufficient color contrast

### 🚫 **What NOT to Use**
- **Custom CSS Classes**: Avoid creating custom CSS classes when Bootstrap components exist
- **Tailwind CSS**: Do not use Tailwind utility classes
- **Flowbite**: Do not use Flowbite components
- **Inline Styles**: Avoid inline styles; use Bootstrap classes instead
- **Custom Form Styling**: Don't create custom form input styling

### ✅ **Implementation Guidelines**
1. **Check Bootstrap First**: Always check if Bootstrap has a component before building custom
2. **Consistent Spacing**: Use Bootstrap's spacing system (`mb-3`, `p-4`, `gap-3`)
3. **Icon Integration**: Use Bootstrap Icons with Bootstrap components
4. **State Management**: Handle loading, error, and success states with Bootstrap patterns
5. **Form Validation**: Use Bootstrap's validation styling (`is-invalid`, `invalid-feedback`)

### 🔧 **Technical Standards**
- **Rails 8**: Follow Rails 8 best practices
- **Propshaft**: Use Propshaft for asset pipeline
- **Importmap**: Use Importmap for JavaScript modules
- **Turbo**: Ensure all forms work with Turbo (add `local: true` if needed)
- **Devise**: Style Devise forms with Bootstrap components

### 📋 **Code Review Checklist**
- [ ] All UI components use Bootstrap styling
- [ ] Forms have proper labels and IDs
- [ ] Buttons use Bootstrap button classes
- [ ] Layout uses Bootstrap grid system
- [ ] Colors follow the Bootstrap color scheme
- [ ] Components are responsive
- [ ] Accessibility requirements met
- [ ] No custom CSS classes for components
- [ ] Error states properly styled
- [ ] Focus states visible and functional

### 🎨 **Examples**

#### Form Input:
```erb
<label for="field_name" class="form-label">
  Field Label <span class="text-danger">*</span>
</label>
<%= f.text_field :field_name, 
    id: "field_name",
    class: "form-control #{'is-invalid' if @model.errors[:field_name].any?}",
    placeholder: "Enter value",
    required: true %>
<% if @model.errors[:field_name].any? %>
  <div class="invalid-feedback"><%= @model.errors[:field_name].first %></div>
<% end %>
```

#### Primary Button:
```erb
<%= f.submit "Save Changes", class: "btn btn-primary" %>
```

#### Card Component:
```erb
<div class="card">
  <div class="card-header">
    <h2 class="h5 fw-semibold mb-0">Card Title</h2>
  </div>
  <div class="card-body">
    <!-- Card content -->
  </div>
</div>
```

#### Grid Layout:
```erb
<div class="container">
  <div class="row">
    <div class="col-md-8">
      <!-- Main content -->
    </div>
    <div class="col-md-4">
      <!-- Sidebar -->
    </div>
  </div>
</div>
```

#### Navigation:
```erb
<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top">
  <div class="container">
    <a class="navbar-brand" href="#">Brand</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link" href="#">Link</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
```

#### Alert Messages:
```erb
<div class="alert alert-success alert-dismissible fade show" role="alert">
  <i class="bi bi-check-circle me-2"></i>
  Success message
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
```

---

**Remember**: When in doubt, check the Bootstrap documentation first. Consistency in design and user experience is paramount for AdLocal.
