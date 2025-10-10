# AdLocal Development Plan

## Current Application State

### ✅ Completed Epics (A, B, C)

#### Epic A — Onboarding & Account ✅
- **Sign in**: Devise authentication implemented with secure login
- **Account setup**: Business profiles with name, industry, and contact information
- **Brand profile**: Brand colors, fonts, tone words saved and auto-applied to campaigns

#### Epic B — Asset Uploads ✅
- **Direct logo upload**: Active Storage integration with drag/drop support
- **Inspiration images**: Multiple image upload with thumbnails and removal capability
- **Asset safety checks**: File type validation and size limits implemented

#### Epic C — Creative Brief & Prompting ✅
- **Brief input**: Comprehensive campaign brief with goals, audience, offer, CTA fields
- **Guided prompts**: Quick prompt suggestions and structured brief composition
- **Brand guardrails**: Brand profile inheritance from business with campaign-level overrides

### Current Features Implemented
- User authentication and authorization
- Business profile management with brand assets
- Campaign creation, editing, and management
- Campaign status system (draft, ready, active, completed)
- Required field validations and completion tracking
- AI integration foundation (OpenAI API)
- Responsive Bootstrap UI with Flowbite components
- File uploads via Active Storage
- Campaign completion percentage calculation
- Standardized "Generate Ads" button styling

---

## 🚧 Remaining Epics to Implement (D through K)

### Epic D — Ad Generation (Realtime, No Refresh) ✅ **COMPLETED**

**Status**: Fully implemented with real-time streaming

#### 10. Generate concepts (streaming) ✅
- **Current State**: Fully implemented with real-time streaming
- **Implementation Completed**:
  - Real-time streaming of AI-generated copy via ActionCable
  - Progress indicators during generation with live updates
  - No page refresh during generation process
  - WebSocket/ActionCable integration for live updates
  - Comprehensive OpenAI prompt that incorporates campaign brief, goals, offer details, target audience, call to action, brand profile and assets
  - Campaign brief, goals, target audience and offer details help generate relevant messaging
  - Call to action incorporated verbatim into ads
  - Brand colors, fonts and tone words guide design treatment
  - Logo integration and inspiration image guidance implemented

#### 11. Multi-size outputs ✅
- **Current State**: Fully implemented
- **Implementation Completed**:
  - Generate images for each selected ad size (300×250, 728×90, 160×600, 300×600, 320×50)
  - Display generated images in appropriate size tiles
  - Size-specific optimization with proper aspect ratios

#### 12. Variant count ✅
- **Current State**: Fully implemented
- **Implementation Completed**:
  - Generate 3 creative variants per run (A, B, C)
  - Label variants with clear identification
  - Display variants side-by-side for comparison
  - Each variant includes headline, subheadline, CTA, and reasoning

#### 13. Cost controls 🚧
- **Current State**: Basic implementation needed
- **Implementation Needed**:
  - Credit/usage tracking system
  - Pre-generation cost estimates
  - Credit deduction on successful generations
  - Usage dashboard

---

### Epic E — Results Review & Editing

#### 14. Inline review
- **Implementation Needed**:
  - Card-based display of generated variants
  - Hover-to-zoom functionality
  - Metadata display (size, generation seed)
  - Copy + image preview per variant

#### 15. Quick edits
- **Implementation Needed**:
  - Inline copy editing
  - "Regenerate image" for specific variants
  - "Regenerate copy" functionality
  - Preserve other variants during editing

#### 16. Replace inspiration mid-stream
- **Implementation Needed**:
  - Dynamic inspiration image management
  - Re-run generation with updated assets
  - Asset modification persistence

#### 17. Select & favorite
- **Implementation Needed**:
  - Favorites system with star ratings
  - Pin favorites to top of results
  - Favorites persistence across sessions

#### 18. Download assets
- **Implementation Needed**:
  - PNG/JPG download for individual variants
  - Bulk download functionality
  - Zipped multi-size downloads
  - Copy deck generation

---

### Epic F — Projects & History

#### 19. Project autosave
- **Implementation Needed**:
  - Auto-save functionality after each action
  - "Saved" status indicators
  - Draft preservation

#### 20. Version history
- **Implementation Needed**:
  - Generation history tracking
  - Timeline view of previous generations
  - Restore previous versions
  - Version comparison

#### 21. Duplicate project
- **Implementation Needed**:
  - Clone campaign functionality
  - Selective copying (brief, assets, settings)
  - Exclude previous outputs option

---

### Epic G — Branding, Compliance & Moderation

#### 22. Logo placement rule
- **Implementation Needed**:
  - Safe-area logo placement algorithms
  - Non-overlap zone preservation
  - Logo compositing options

#### 23. Claims & sensitive content checks
- **Implementation Needed**:
  - Content moderation system
  - Risky claims detection
  - Compliance warnings and suggestions
  - Pre-download validation

#### 24. Copyright & imagery policy
- **Implementation Needed**:
  - Brand similarity detection
  - Copyright risk assessment
  - User confirmation for flagged content
  - Legal guidance integration

---

### Epic H — Billing, Quotas & Roles

#### 25. Plan limits
- **Implementation Needed**:
  - Usage tracking system
  - Monthly generation limits
  - Storage quota management
  - Real-time usage dashboard

#### 26. Top-up
- **Implementation Needed**:
  - Credit purchase system
  - Payment integration
  - Immediate credit availability
  - Transaction history

#### 27. Teammate access (optional)
- **Implementation Needed**:
  - User invitation system
  - Role-based permissions
  - Collaboration features
  - Audit logging

---

### Epic I — Notifications & Guidance

#### 28. Realtime progress
- **Implementation Needed**:
  - Live progress indicators
  - Generation state tracking (queued → generating → ready)
  - Streaming token display
  - Status updates without refresh

#### 29. Tips & best practices
- **Implementation Needed**:
  - Contextual help system
  - Inline tips and guidance
  - Dismissible help content
  - Best practices integration

#### 30. Email summary (optional)
- **Implementation Needed**:
  - Email notification system
  - Best variants summary
  - Secure download links
  - Configurable email preferences

---

### Epic J — Accessibility, Performance & Reliability (NFRs)

#### 31. A11y
- **Implementation Needed**:
  - WCAG compliance audit
  - Keyboard navigation support
  - ARIA labels for streaming content
  - Screen reader compatibility

#### 32. Latency
- **Implementation Needed**:
  - Performance optimization
  - Non-blocking UI during generation
  - Responsive design improvements
  - Loading state management

#### 33. Resilience
- **Implementation Needed**:
  - Error handling and retry logic
  - Graceful failure recovery
  - Credit restoration on failures
  - Clear error messaging

---

### Epic K — Support & Help

#### 34. In-app help
- **Implementation Needed**:
  - Help documentation system
  - Searchable help modal
  - Contextual help links
  - Video tutorial integration

#### 35. Contact support
- **Implementation Needed**:
  - Support ticket system
  - Context-aware error reporting
  - Project state inclusion in tickets
  - Support dashboard

---

## Implementation Priority

### Phase 1: Core Generation (Epic D) ✅ **COMPLETED**
1. **Streaming AI generation** - Real-time copy generation ✅
2. **Multi-size image generation** - Generate images for all selected sizes ✅
3. **Variant system** - Multiple creative variants per generation ✅
4. **Cost controls** - Basic credit system 🚧

### Phase 2: Review & Editing (Epic E)
1. **Inline review interface** - Card-based variant display
2. **Quick editing** - Regenerate specific elements
3. **Download functionality** - Asset export capabilities

### Phase 3: Project Management (Epic F)
1. **Auto-save** - Draft preservation
2. **Version history** - Generation tracking
3. **Project duplication** - Clone functionality

### Phase 4: Compliance & Safety (Epic G)
1. **Content moderation** - Safety checks
2. **Brand compliance** - Logo placement rules
3. **Copyright protection** - Risk assessment

### Phase 5: Business Features (Epic H)
1. **Usage tracking** - Quota management
2. **Billing system** - Credit purchases
3. **Team collaboration** - Multi-user support

### Phase 6: User Experience (Epic I)
1. **Progress indicators** - Real-time feedback
2. **Help system** - User guidance
3. **Email notifications** - Summary reports

### Phase 7: Quality & Support (Epic J & K)
1. **Accessibility** - WCAG compliance
2. **Performance** - Optimization
3. **Support system** - Help and tickets

---

## Technical Requirements

### Current Tech Stack
- **Rails 8** with Propshaft asset pipeline
- **Bootstrap 5** with Flowbite components
- **Devise** for authentication
- **Active Storage** for file uploads
- **OpenAI API** for AI content generation
- **Stimulus.js** for interactive UI
- **Importmap** for JavaScript modules

### Additional Technologies Needed
- **ActionCable** for real-time streaming
- **WebSocket** for live updates
- **Image processing** (MiniMagick/ImageMagick)
- **Payment processing** (Stripe/PayPal)
- **Email service** (ActionMailer/SendGrid)
- **Background jobs** (Solid Queue)
- **Caching** (Redis/Memcached)

---

## Definition of Done (Global)

- All flows work without page refresh (Turbo/Stimulus/fetch)
- Server keys never exposed; uploads use direct S3; signed URLs are short-lived
- Errors are actionable, not generic
- Telemetry: generation duration, success rate, credit consumption captured
- Unit + request specs for all new features
- End-to-end testing for critical user flows
- WCAG compliance maintained
- Performance benchmarks met

---

## Implementation Status

### ✅ Completed (Phase 1-8)
- [x] Database migration for compositor fields
- [x] OpenAI Ad Generator updated for background image generation
- [x] Ad Generation Job updated for new workflow
- [x] MiniMagick gem added and configured
- [x] ImageCompositorService created for server-side composition
- [x] AdCompositorController with all required actions
- [x] Compositor UI with canvas preview and controls
- [x] JavaScript controller for drag-and-drop functionality
- [x] Campaign show view updated for compositor workflow
- [x] Model methods added (editable?, has_final_image?, etc.)
- [x] Routes configured for ad compositor

### 🔄 Remaining Tasks
- [ ] Write comprehensive tests for all new components
- [ ] Add loading states and keyboard shortcuts to compositor UI
- [ ] Implement preview functionality and visual guidelines
- [ ] Add snap-to-grid option for positioning
- [ ] Test full workflow: generate → position → render
- [ ] Performance optimization for image processing
- [ ] Error handling improvements
- [ ] Documentation updates

---

*Last updated: [Current Date] - Ad Compositor System Phase 1-8 Complete*
