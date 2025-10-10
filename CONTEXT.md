# AdLocal Rails 8 Application - Context

## Project Overview
AdLocal is a Rails 8 application for small businesses to create AI-powered advertising campaigns. Built with Bootstrap for UI, Devise for authentication, and Active Storage for file uploads.

## Current Architecture

### Models
- **User**: Devise authentication
- **Business**: Company profiles with brand information (logo, colors, fonts, tone)
- **Campaign**: Advertising campaigns with AI-generated content
- **ContactPerson**: Business contact information
- **GeneratedAd**: AI-generated ad variants with images and copy

### Key Features Implemented
- User authentication (Devise)
- Business profile management with brand assets
- Campaign creation and management
- AI-powered ad generation with real-time streaming (OpenAI integration)
- Multi-variant, multi-size ad generation
- Real-time progress updates via ActionCable
- File uploads (Active Storage)
- Responsive Bootstrap UI with Flowbite components

### Database Schema
- Users table (Devise)
- Businesses table with brand profile fields
- Campaigns table with AI-generated content
- Generated ads table for storing AI-generated variants
- Contact people table
- Active Storage attachments for logos and inspiration images

## Recent Changes (Latest Session)
- ✅ Added homepage images to story cards (hpimage_one.png, hpimage_two.png, hpimage_three.png)
- ✅ Implemented campaign status system (draft, ready, active, completed)
- ✅ Added required field validations for campaigns (brief, goals, audience, offer, ad_sizes)
- ✅ Consolidated campaign forms into shared partial (_form.html.erb)
- ✅ Brand profile management moved to business level
- ✅ Default ad sizes selection for new campaigns
- ✅ Campaign completion percentage calculation
- ✅ Logo upload requirements for business profiles
- ✅ Standardized element (buttons, menus, dropdowns, input boxes, labels, etc) styling across application
- ✅ Implemented Epic D - AI Ad Generation with real-time streaming
- ✅ Created comprehensive OpenAI prompt template for ad generation
- ✅ Set up ActionCable for real-time updates
- ✅ Built multi-variant, multi-size ad generation system
- ✅ Added GeneratedAd model for storing generated content
- ✅ Wired up Generate Ads buttons across all campaign views
- ✅ Fixed Rails 8 compatibility issues with deprecated method: syntax
- ✅ Fixed generate_ads action missing from set_campaign before_action
- ✅ Fixed ActionCable import issues in Stimulus controller
- ✅ Created ApplicationCable base classes for ActionCable
- ✅ Temporarily disabled ActionCable to fix immediate functionality
- ✅ Updated ad generation to create only 1 variant instead of 3
- ✅ Changed ad labels to display ad size instead of "Variant X"
- ✅ Re-enabled ActionCable with proper Rails 8 configuration
- ✅ Implemented real-time streaming of generation progress via ActionCable
- ✅ Added proper Devise authentication for ActionCable connections
- ✅ Connected to real OpenAI API for actual ad generation
- ✅ Added OpenAI organization ID for enterprise account support

## Current State
- All tests passing
- Homepage with three story cards displaying images
- Campaign creation/edit forms with proper validations
- Business profiles with logo upload requirements
- AI integration for campaign suggestions
- Responsive Bootstrap UI with consistent styling

## Technical Stack
- **Rails 8** with Propshaft asset pipeline
- **Bootstrap 5** with Flowbite components
- **Devise** for authentication
- **Active Storage** for file uploads
- **OpenAI API** for AI content generation
- **Stimulus.js** for interactive UI
- **Importmap** for JavaScript modules

## Key Files Structure
```
app/
├── models/
│   ├── user.rb (Devise)
│   ├── business.rb (brand profile, logo)
│   ├── campaign.rb (AI content, validations)
│   └── contact_person.rb
├── controllers/
│   ├── businesses_controller.rb
│   ├── campaigns_controller.rb
│   └── contact_people_controller.rb
├── views/
│   ├── home/index.html.erb (homepage with images)
│   ├── campaigns/
│   │   ├── _form.html.erb (shared partial)
│   │   ├── new.html.erb
│   │   ├── edit.html.erb
│   │   └── show.html.erb
│   └── businesses/
│       ├── _form.html.erb
│       └── show.html.erb
└── assets/
    └── images/
        ├── hpimage_one.png
        ├── hpimage_two.png
        └── hpimage_three.png
```

## Campaign Status System
- **draft**: Created but incomplete info, no ads generated
- **ready**: Complete info, ads created
- **active**: Complete info, ads created, campaign live
- **completed**: Campaign finished

## Required Fields
### Business Profile
- Logo upload (required on creation, optional on update if exists)
- Brand colors, tone words, fonts (optional but recommended)

### Campaign
- Name, brief (min 20 chars), goals, audience, offer
- At least one ad size selection
- Brand profile (inherits from business, overrideable)

## AI Integration
- OpenAI API for campaign suggestions
- Brief-based content generation
- Error handling for API failures

## Testing Status
- All model tests passing
- All controller tests passing
- Fixtures properly configured
- Logo upload tests implemented

## Next Steps / Backlog
- [ ] Implement campaign activation functionality
- [ ] Add campaign analytics/insights
- [ ] Enhance AI prompt engineering
- [ ] Add more ad size options
- [ ] Implement campaign live status
- [ ] Add campaign performance tracking

## Development Notes
- Use Flowbite components for all UI elements
- Follow Rails 8 best practices
- Maintain responsive design
- Ensure accessibility compliance
- Test coverage for all new features

## UI Standards
### Generate Ads Button
- **Standard styling**: `btn btn-outline-primary` with magic wand icon
- **Icon**: `<i class="bi bi-magic me-1"></i>` (Bootstrap Icons)
- **Size**: `btn-lg` for show page, `btn-sm` for index cards
- **Consistent across**: campaigns/show.html.erb and campaigns/index.html.erb
- **Purpose**: Clearly indicates AI-powered functionality

### Comprehensive Styling Standards
- **Document**: `STYLING_STANDARDS.md` contains complete UI guidelines
- **Button Standards**: All buttons use outlined variants (`btn-outline-primary`, `btn-outline-secondary`)
- **Form Standards**: Consistent labels (`form-label fw-bold`), validation styling (`is-invalid`, `invalid-feedback`)
- **Card Standards**: Standardized card structure with headers and shadows
- **Color Scheme**: Bootstrap color palette with red primary (`#dc3545`)
- **Typography**: `fw-bold` for headings, `text-muted` for secondary text
- **Icons**: Bootstrap Icons with consistent spacing (`me-2`, `me-1`)
- **Responsive**: Mobile-first design with `md:` and `lg:` breakpoints

## Common Commands
```bash
# Run tests
rails test

# Run specific test file
rails test test/models/campaign_test.rb

# Run RuboCop
rubocop -A

# Start development server
bin/dev
```

## Context Management
This file should be updated after each significant change to maintain context across AI assistant sessions. Include:
- New features implemented
- Bug fixes applied
- Architecture changes
- Testing updates
- Next priorities

## Recent Fixes
- `Fixed OpenAI image generation 400 errors by removing unsupported quality parameter`
- `Identified root cause: quality: "standard" parameter not supported by DALL-E API`
- `Image generation now works correctly with real OpenAI API calls`
- `Updated image generation to create complete ads with text overlay instead of just background images`
- `Added build_complete_ad_prompt method to include headline, subheadline, call-to-action, and business name in generated images`
- `Added delete_ads functionality to remove all generated ads and reset campaign to draft status`
- `Removed placeholder image fallback - ad generation now fails completely if OpenAI API fails`
- `Fixed 400 errors by simplifying image generation prompt to avoid content policy violations`
- `Fixed ActionCable real-time updates by broadcasting saved GeneratedAd records instead of raw variants`
- `Added extensive debugging to ActionCable JavaScript controller to troubleshoot connection issues`
- `Fixed ActionCable import issue in Rails 8 by using ES6 import instead of window.ActionCable`
- `✅ RESOLVED: ActionCable real-time updates now working with Rails 8 + Importmap`
- `Optimized CSS preloading warning by adding media="all" attribute to stylesheet_link_tag`
- `Restructured campaign show page with Bootstrap tabs: Campaign Brief, Generate Ads, Choose Inventory`
- `Updated all tabs to use full-width layout (col-12) for consistent design`
- `Moved Campaign Completion Status card to header section above tabs for better visibility`
- `Updated campaign completion percentage to include ad generation as a required field`
- `Added granular campaign status messages: "Ready to generate ads", "Ready to pick inventory", etc.`
- `Simplified campaign show view to 4 tabs: Campaign Brief, Generate Background Image, Create Ads, Choose Inventory`
- `Tab 2 (Generate Background Image): Only shows generate/regenerate button and background image display`
- `Tab 3 (Create Ads): Contains all ad creation and editing functionality with drag-and-drop interface`
- `Tab 4 (Choose Inventory): Placeholder for inventory selection functionality`
- `Button automatically changes from "Generate Image" to "Regenerate Image" after generation`
- `Removed complex workflow from Tab 2 - now focused solely on background image generation`
- `Added comprehensive debugging to OpenAI image generation to log exact prompts and parameters`
- `Implemented balanced prompt with layout instructions for different ad sizes while avoiding content policy issues`

---
*Last updated: [Current Date] - Simplified campaign workflow to 4 focused tabs with streamlined background image generation*
