# Implementation Plan: Debriefly

## Overview

This implementation plan breaks down the Debriefly application into discrete coding tasks. The system consists of a Flutter frontend (iOS, Android, Web) and a Nest.js backend with RESTful API. Implementation follows an incremental approach: backend data layer → API endpoints → frontend models → UI components → integration → testing.

## Tasks

- [x] 1. Set up project structure and dependencies
  - Create Nest.js backend project with TypeScript configuration
  - Create Flutter frontend project with multi-platform support
  - Install backend dependencies: @nestjs/common, @nestjs/typeorm, pg (or mongoose), class-validator, class-transformer, nodemailer
  - Install frontend dependencies: provider (or riverpod), dio, flutter_form_builder, flutter_datetime_picker, url_launcher
  - Configure database connection (PostgreSQL or MongoDB)
  - Set up environment variables for database and email service
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 2. Implement backend data models and database schema
  - [x] 2.1 Create Debrief entity with TypeORM or Mongoose
    - Define Debrief entity with fields: id, clientName, meetingDate, participants, summary, decisionsMade, actionItems, risksConcerns, createdBy, createdAt, updatedAt
    - Define ActionItem embedded type/schema with description, owner, dueDate
    - Add database indexes for createdBy, meetingDate, and clientName
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
- [x] 3. Implement backend repository layer
  - [x] 3.1 Create DebriefRepository with database operations
    - Implement create(debrief): Promise<Debrief>
    - Implement findAll(userId): Promise<Debrief[]>
    - Implement findById(id): Promise<Debrief | null>
    - Implement update(id, debrief): Promise<Debrief>
    - Implement delete(id): Promise<void>
    - _Requirements: 2.1, 2.5, 2.6, 2.7, 3.1_

- [x] 4. Implement backend DTOs and validation
  - [x] 4.1 Create request and response DTOs
    - Create CreateDebriefDto with class-validator decorators
    - Create UpdateDebriefDto with optional fields
    - Create EmailDebriefDto with recipient validation
    - Create ActionItemDto with required field validation
    - Create DebriefResponseDto for API responses
    - Create ErrorResponseDto for error responses
    - _Requirements: 8.6, 8.7, 10.1, 10.2, 10.3, 10.4_

- [x] 5. Implement backend service layer
  - [x] 5.1 Create DebriefService with business logic
    - Implement create(createDebriefDto, userId): Promise<Debrief>
    - Implement findAll(userId): Promise<Debrief[]>
    - Implement findOne(id): Promise<Debrief>
    - Implement update(id, updateDebriefDto): Promise<Debrief>
    - Implement remove(id): Promise<void>
    - Implement formatForEmail(debrief): string method
    - _Requirements: 1.8, 1.9, 2.6, 3.1, 7.5, 7.6_

- [x] 6. Implement email service
  - [x] 6.1 Create EmailService with nodemailer or SendGrid
    - Implement sendDebriefEmail(recipients, subject, content): Promise<void>
    - Configure email transport with environment variables
    - Add error handling and logging for email failures
    - _Requirements: 7.4, 7.5, 7.6_

- [x] 7. Implement backend API controller and endpoints
  - [x] 7.1 Create DebriefController with REST endpoints
    - Implement POST /debriefs endpoint (create)
    - Implement GET /debriefs endpoint (findAll)
    - Implement GET /debriefs/:id endpoint (findOne)
    - Implement PUT /debriefs/:id endpoint (update)
    - Implement DELETE /debriefs/:id endpoint (remove)
    - Implement POST /debriefs/:id/email endpoint (sendEmail)
    - Add validation pipes to all endpoints
    - Add authentication middleware (placeholder for MVP)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8_

- [x] 8. Checkpoint - Ensure backend tests pass
  - Run all backend unit tests, property tests, and integration tests
  - Verify API endpoints respond correctly
  - Ensure all tests pass, ask the user if questions arise

- [x] 9. Implement Flutter data models
  - [x] 9.1 Create Dart data models for Debrief and ActionItem
    - Create Debrief class with all fields
    - Create ActionItem class with description, owner, dueDate
    - Implement fromJson factory constructors
    - Implement toJson methods
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 10. Implement Flutter API service layer
  - [x] 10.1 Create DebriefService with dio HTTP client
    - Configure dio with base URL and interceptors
    - Implement createDebrief(debrief): Future<Debrief>
    - Implement getDebriefs(): Future<List<Debrief>>
    - Implement getDebriefById(id): Future<Debrief>
    - Implement updateDebrief(id, debrief): Future<Debrief>
    - Implement deleteDebrief(id): Future<void>
    - Implement sendDebriefEmail(id, recipients): Future<void>
    - Add error handling for network failures
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 11. Implement Flutter state management
  - [x] 11.1 Create DebriefProvider or Notifier with Provider/Riverpod
    - Implement state for list of debriefs
    - Implement state for current debrief
    - Implement state for loading, error states
    - Implement methods: loadDebriefs(), createDebrief(), updateDebrief(), deleteDebrief()
    - Add error handling and state updates
    - _Requirements: 1.8, 1.9, 1.10, 3.1_

- [x] 12. Implement Dashboard screen
  - [x] 12.1 Create Dashboard UI with debrief list
    - Create DashboardScreen widget
    - Create DebriefCard widget displaying clientName, meetingDate, summary preview
    - Implement card-based layout with dark navy, white, warm amber colors
    - Add navigation to detail view on card tap
    - Add FloatingActionButton for creating new debrief
    - Add EmptyState widget for no debriefs
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

- [x] 13. Implement search and filter functionality
  - [x] 13.1 Add search and date range filter to Dashboard
    - Create SearchBar widget with text input
    - Create DateRangeFilter widget with date pickers
    - Implement client name filtering (case-insensitive)
    - Implement date range filtering
    - Update debrief list based on filters
    - Display "no results" message when filters match nothing
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 14. Implement Debrief Form screen
  - [x] 14.1 Create form UI with all input fields
    - Create DebriefFormScreen widget
    - Create ClientNameField text input
    - Create MeetingDatePicker with current date default
    - Create ParticipantsField text input
    - Create BulletPointField multi-line text area for summary
    - Create BulletPointField multi-line text area for decisions
    - Create ActionItemList with dynamic add/remove
    - Create ActionItemRow with description, owner, dueDate fields
    - Create RisksConcerns optional text area
    - Apply dark navy, white, warm amber color scheme
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [x] 14.2 Implement form validation logic
    - Add required field validation for clientName
    - Add required field validation for meetingDate
    - Add required field validation for action item fields (description, owner, dueDate)
    - Add date format validation
    - Display inline error messages near invalid fields
    - Highlight invalid fields with red border
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [x] 14.3 Implement form submission and navigation
    - Enable submit button only when form is valid
    - Disable submit button when form is invalid
    - Submit form data to API on button press
    - Navigate to detail view on successful creation
    - Display error message on submission failure
    - _Requirements: 1.8, 1.9, 1.10, 10.6, 10.7_

- [ ] 15. Checkpoint - Ensure frontend form tests pass
  - Run all Flutter widget tests and property tests for form
  - Verify form validation works correctly
  - Ensure all tests pass, ask the user if questions arise

- [ ] 16. Implement Detail View screen
  - [ ] 16.1 Create detail view UI with all debrief fields
    - Create DetailViewScreen widget
    - Create DebriefHeader displaying clientName and meetingDate
    - Create ParticipantsSection displaying participants list
    - Create SummarySection displaying bullet points
    - Create DecisionsSection displaying bullet points
    - Create ActionItemsSection displaying table/list with description, owner, dueDate
    - Create RisksSection displaying risks/concerns text
    - Apply dark navy, white, warm amber color scheme with card layouts
    - _Requirements: 5.1, 5.2, 5.3, 5.5, 5.6, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [ ]\* 16.2 Write property test for detail view rendering completeness
    - **Property 8: Detail View Rendering Completeness**
    - **Validates: Requirements 5.1, 5.2, 5.3**
    - Generate Debrief objects with all fields, render detail view, verify all fields present

  - [ ]\* 16.3 Write widget tests for detail view
    - Test all sections render correctly
    - Test display of all debrief fields
    - Test handling of optional fields
    - _Requirements: 5.1, 5.2, 5.3, 5.5, 5.6_

- [ ] 17. Implement shareable URL and copy link functionality
  - [ ] 17.1 Add URL generation and copy link feature
    - Generate unique URLs with debrief ID in format /debriefs/:id
    - Add "Copy Link" button to detail view
    - Implement clipboard copy functionality
    - Display confirmation message on successful copy
    - Configure routing to handle /debriefs/:id URLs
    - Load and display debrief when navigating to unique URL
    - _Requirements: 5.4, 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ]\* 17.2 Write property test for URL generation and routing
    - **Property 9: URL Generation and Routing**
    - **Validates: Requirements 5.4, 6.2, 6.3, 6.4**
    - Generate debrief IDs, create URLs, verify ID present in URL and routing works

  - [ ]\* 17.3 Write widget tests for copy link
    - Test copy link button renders
    - Test clipboard copy on button press
    - Test confirmation message display
    - _Requirements: 6.1, 6.2, 6.5_

- [ ] 18. Implement email sharing functionality
  - [ ] 18.1 Create email modal and email sending
    - Create EmailModal dialog widget
    - Create RecipientField for email input (supports multiple addresses)
    - Add email address validation
    - Add "Send" and "Cancel" buttons
    - Implement email sending via API on send button press
    - Display confirmation message on successful send
    - Display error message on send failure
    - Add "Email Debrief" button to detail view
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.7, 7.8_

  - [ ]\* 18.2 Write widget tests for email modal
    - Test modal display on button press
    - Test recipient input
    - Test email validation
    - Test send button functionality
    - Test confirmation and error messages
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.7, 7.8_

- [ ] 19. Integration and end-to-end wiring
  - [ ] 19.1 Wire all components together
    - Connect Dashboard to API service
    - Connect Form to API service
    - Connect Detail View to API service
    - Configure navigation routes between screens
    - Test complete user flows: create → view → share → email
    - Verify error handling across all screens
    - _Requirements: 1.10, 3.5, 6.4_

  - [ ]\* 19.2 Write E2E integration tests
    - Test complete debrief creation flow
    - Test dashboard search and filter flow
    - Test detail view and sharing flow
    - Test email sending flow
    - Test error scenarios across flows
    - _Requirements: 1.8, 1.9, 1.10, 3.1, 3.5, 4.2, 4.4, 5.4, 6.4, 7.4_

- [ ] 20. Final checkpoint - Ensure all tests pass
  - Run all backend tests (unit, property, integration)
  - Run all frontend tests (unit, property, widget, E2E)
  - Verify all 16 correctness properties pass
  - Test application manually on web, iOS simulator, Android emulator
  - Ensure all tests pass, ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Property-based tests validate the 16 correctness properties from the design document
- Backend uses TypeScript with Nest.js, frontend uses Dart with Flutter
- Checkpoints ensure incremental validation at key milestones
- All UI components follow the dark navy, white, and warm amber color palette
- Testing strategy includes unit tests, property tests, integration tests, and E2E tests
