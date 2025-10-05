# Development Rules for AdLocal Rails Application

## Project Overview
This is a Ruby on Rails 8 application with PostgreSQL 16 and Bootstrap 5.

## Technology Stack
- **Backend**: Ruby on Rails 8.0.3
- **Database**: PostgreSQL 16
- **Frontend**: Bootstrap 5
- **JavaScript**: Stimulus + Turbo (Hotwire)
- **Asset Pipeline**: Propshaft
- **Job Processing**: Solid Queue
- **Caching**: Solid Cache
- **WebSocket**: Solid Cable

## Code Style and Standards

### Ruby/Rails Standards
- Follow the rules defined in `.rubocop.yml`
- Use RuboCop Rails Omakase configuration as base
- Target Ruby version: 3.3
- Maximum line length: 120 characters
- Use single quotes for strings
- Use frozen string literal comments
- Follow Rails conventions for naming and structure

### JavaScript Standards
- Follow the rules defined in `.eslintrc.js`
- Use ES6+ features
- Use Stimulus controllers for interactive components
- Use Turbo for page navigation and form submissions
- Maximum line length: 120 characters
- Use single quotes for strings
- Use semicolons

### CSS Standards
- Use Bootstrap 5 utility classes and components
- Follow the rules defined in `.stylelintrc.json`
- Use Bootstrap components when available
- Custom CSS should be minimal and component-specific
- Use CSS custom properties for theme values
- Maximum line length: 120 characters

### Database Standards
- Follow the rules defined in `.postgresql_rules.md`
- Use UUID for primary keys when appropriate
- Always add indexes for foreign keys
- Use proper naming conventions (snake_case, plural table names)
- Write reversible migrations
- Use database constraints as backup for validations

## Project Structure

### Directory Organization
```
app/
├── assets/           # Static assets
│   ├── builds/      # Compiled assets
│   ├── images/      # Image files
│   └── stylesheets/ # CSS files
├── controllers/     # Rails controllers
├── helpers/         # View helpers
├── javascript/      # JavaScript files
│   └── controllers/ # Stimulus controllers
├── jobs/            # Background jobs
├── mailers/         # Email templates and logic
├── models/          # ActiveRecord models
└── views/           # ERB templates
```

### File Naming Conventions
- **Controllers**: `snake_case_controller.rb`
- **Models**: `snake_case.rb` (singular)
- **Views**: `snake_case.html.erb`
- **Helpers**: `snake_case_helper.rb`
- **Jobs**: `snake_case_job.rb`
- **Mailers**: `snake_case_mailer.rb`
- **Stimulus Controllers**: `snake_case_controller.js`
- **CSS**: `snake_case.css`

## Development Workflow

### Getting Started
1. Clone the repository
2. Run `bundle install`
3. Run `rails db:create db:migrate db:seed`
4. Run `rails server`
5. Visit `http://localhost:3000`

### Code Quality Checks
Before committing, run:
```bash
# Ruby code quality
bundle exec rubocop

# JavaScript code quality
npx eslint app/javascript/

# CSS code quality
npx stylelint "app/assets/**/*.css"

# Run tests
rails test
```

### Git Workflow
1. Create feature branches from `main`
2. Use descriptive commit messages
3. Run code quality checks before committing
4. Create pull requests for code review
5. Merge to `main` after approval

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
Scopes: `api`, `ui`, `db`, `config`, etc.

Examples:
- `feat(auth): add user registration`
- `fix(api): handle missing parameters`
- `docs(readme): update installation instructions`

## Testing Standards

### Test Organization
- Unit tests in `test/models/`
- Controller tests in `test/controllers/`
- Integration tests in `test/integration/`
- System tests in `test/system/`
- Helper tests in `test/helpers/`

### Test Naming
- Test files: `model_name_test.rb`
- Test methods: `test_should_do_something`

### Test Structure
```ruby
class UserTest < ActiveSupport::TestCase
  test "should create user with valid attributes" do
    # Arrange
    user = User.new(valid_attributes)
    
    # Act
    result = user.save
    
    # Assert
    assert result
    assert_equal expected_value, user.attribute
  end
end
```

## Security Guidelines

### General Security
- Never commit secrets or credentials
- Use environment variables for sensitive data
- Implement proper authentication and authorization
- Validate all user inputs
- Use HTTPS in production
- Keep dependencies updated

### Rails Security
- Use `has_secure_password` for user authentication
- Implement CSRF protection
- Use strong parameters
- Validate file uploads
- Use Rails' built-in security features

### Database Security
- Use parameterized queries
- Implement proper access controls
- Encrypt sensitive data
- Use database-level constraints
- Regular security audits

## Performance Guidelines

### General Performance
- Monitor application performance
- Use caching strategies
- Optimize database queries
- Minimize asset sizes
- Use CDN for static assets

### Rails Performance
- Use `includes` to avoid N+1 queries
- Implement proper indexing
- Use background jobs for heavy tasks
- Cache expensive operations
- Monitor memory usage

### Frontend Performance
- Optimize images
- Minimize JavaScript bundles
- Use lazy loading
- Implement proper caching headers
- Monitor Core Web Vitals

## Deployment Guidelines

### Environment Configuration
- Use environment-specific configurations
- Implement proper logging
- Use health checks
- Monitor application metrics
- Implement proper error handling

### Production Considerations
- Use production-ready web servers
- Implement proper backup strategies
- Use SSL/TLS certificates
- Configure monitoring and alerting
- Implement proper scaling strategies

## Documentation Standards

### Code Documentation
- Document public APIs
- Use clear variable and method names
- Add comments for complex logic
- Keep documentation up to date
- Use consistent formatting

### Project Documentation
- Maintain README with setup instructions
- Document API endpoints
- Keep deployment guides current
- Document configuration options
- Maintain changelog

## Tools and Resources

### Development Tools
- **Ruby**: RVM or rbenv for version management
- **Database**: PostgreSQL 16
- **IDE**: VS Code with Ruby, Rails, and Bootstrap extensions
- **Git**: GitHub for version control
- **Testing**: Rails built-in testing framework

### Useful Gems
- `rubocop-rails-omakase` - Code style enforcement
- `brakeman` - Security vulnerability scanner
- `bullet` - N+1 query detection
- `database_cleaner` - Test database management

### Monitoring Tools
- Application logs
- Database query monitoring
- Performance monitoring
- Error tracking
- Uptime monitoring

## Troubleshooting

### Common Issues
1. **Database connection issues**: Check PostgreSQL service and credentials
2. **Asset compilation issues**: Clear Rails cache and rebuild assets
3. **JavaScript errors**: Check browser console and Stimulus controller setup
4. **Style issues**: Verify Bootstrap CSS compilation and component integration

### Getting Help
1. Check Rails guides and documentation
2. Review error logs in `log/development.log`
3. Use Rails console for debugging: `rails console`
4. Check database state: `rails db:migrate:status`

## Contributing

### Before Contributing
1. Read this development guide
2. Understand the codebase structure
3. Run existing tests
4. Check for open issues

### Making Contributions
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run all quality checks
6. Submit a pull request

### Code Review Process
1. Automated checks must pass
2. Manual review by maintainers
3. Address feedback and suggestions
4. Merge after approval

## Changelog

### Version 1.0.0
- Initial Rails 8 application setup
- PostgreSQL 16 integration
- Bootstrap 5 setup
- Development rules and standards established

### Version 1.1.0
- Migrated from Tailwind CSS + Flowbite to Bootstrap 5
- Updated all views to use Bootstrap components
- Simplified frontend framework for better maintainability
