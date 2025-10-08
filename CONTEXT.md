# AdLocal Rails 8 Application - Context

## Project Overview
AdLocal is a Rails 8 application for small businesses to create AI-powered advertising campaigns. Built with Bootstrap for UI, Devise for authentication, and Active Storage for file uploads.

## Current Architecture

### Models
- **User**: Devise authentication
- **Business**: Company profiles with brand information (logo, colors, fonts, tone)
- **Campaign**: Advertising campaigns with AI-generated content
- **ContactPerson**: Business contact information

### Key Features Implemented
- User authentication (Devise)
- Business profile management with brand assets
- Campaign creation and management
- AI-powered ad generation (OpenAI integration)
- File uploads (Active Storage)
- Responsive Bootstrap UI with Flowbite components

### Database Schema
- Users table (Devise)
- Businesses table with brand profile fields
- Campaigns table with AI-generated content
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

---
*Last updated: [Current Date] - Added homepage images to story cards*
