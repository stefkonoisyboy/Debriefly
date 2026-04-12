# Requirements Document

## Introduction

Debriefly is a tool designed to streamline post-client meeting debrief reporting for account managers, sales teams, and project managers. The system provides a fast, structured, and easily distributable way to share meeting outcomes with colleagues through a Flutter-based frontend (iOS, Android, Web) and a Nest.js backend. This MVP focuses on core debrief creation, viewing, and sharing functionality without AI-powered features.

## Glossary

- **Debriefly_System**: The complete application including Flutter frontend and Nest.js backend
- **Debrief_Form**: The user interface component for creating and editing debrief reports
- **Debrief_Entity**: A structured record containing meeting outcome information stored in the backend
- **Dashboard**: The main list view displaying all created debriefs
- **Detail_View**: A dedicated page showing complete information for a single debrief
- **Action_Item**: A task with description, owner, and due date fields
- **Backend_API**: The Nest.js RESTful API managing debrief data
- **User**: An authenticated account manager, sales team member, or project manager

## Requirements

### Requirement 1: Debrief Creation

**User Story:** As a User, I want to create structured debrief reports through an intuitive form, so that I can quickly document meeting outcomes.

#### Acceptance Criteria

1. THE Debrief_Form SHALL provide a text input field for Client Name
2. THE Debrief_Form SHALL provide a date picker for Meeting Date that auto-fills with the current date
3. THE Debrief_Form SHALL provide a text input field for Participants accepting comma-separated values
4. THE Debrief_Form SHALL provide a multi-line text area for Summary supporting bullet points
5. THE Debrief_Form SHALL provide a multi-line text area for Decisions Made supporting bullet points
6. THE Debrief_Form SHALL provide a dynamic list interface for Action Items with fields for Description, Owner, and Due Date
7. THE Debrief_Form SHALL provide an optional multi-line text area for Risks/Concerns
8. WHEN a User submits a completed Debrief_Form, THE Debriefly_System SHALL create a new Debrief_Entity with a unique identifier
9. WHEN a User submits a Debrief_Form, THE Backend_API SHALL store the Debrief_Entity with createdAt and updatedAt timestamps
10. WHEN a Debrief_Entity is successfully created, THE Debriefly_System SHALL navigate the User to the Detail_View for that debrief

### Requirement 2: Debrief Data Persistence

**User Story:** As a User, I want my debrief data to be reliably stored and retrievable, so that I can access meeting information later.

#### Acceptance Criteria

1. THE Backend_API SHALL store each Debrief_Entity with fields: id, clientName, meetingDate, participants, summary, decisionsMade, actionItems, risksConcerns, createdBy, createdAt, and updatedAt
2. THE Backend_API SHALL store summary as an array of strings representing bullet points
3. THE Backend_API SHALL store decisionsMade as an array of strings representing bullet points
4. THE Backend_API SHALL store actionItems as an array of objects containing description, owner, and dueDate fields
5. THE Backend_API SHALL generate a unique string identifier for each Debrief_Entity
6. WHEN a Debrief_Entity is created, THE Backend_API SHALL record the User ID in the createdBy field
7. WHEN a Debrief_Entity is modified, THE Backend_API SHALL update the updatedAt timestamp

### Requirement 3: Debrief Dashboard Display

**User Story:** As a User, I want to view a list of all my created debriefs, so that I can quickly find and access past meeting reports.

#### Acceptance Criteria

1. THE Dashboard SHALL display a list of all Debrief_Entity records created by the User
2. THE Dashboard SHALL display Client Name for each Debrief_Entity in the list
3. THE Dashboard SHALL display Meeting Date for each Debrief_Entity in the list
4. THE Dashboard SHALL display a brief summary preview for each Debrief_Entity in the list
5. WHEN a User clicks on a Debrief_Entity in the Dashboard, THE Debriefly_System SHALL navigate to the Detail_View for that debrief
6. THE Dashboard SHALL display Debrief_Entity records in a card-based layout with generous whitespace
7. THE Dashboard SHALL use the dark navy, white, and warm amber color palette

### Requirement 4: Search and Filter Functionality

**User Story:** As a User, I want to search and filter debriefs, so that I can quickly locate specific meeting reports.

#### Acceptance Criteria

1. THE Dashboard SHALL provide a search input field for filtering debriefs
2. WHEN a User enters text in the search field, THE Dashboard SHALL filter Debrief_Entity records by Client Name containing the search text
3. THE Dashboard SHALL provide a date range filter interface
4. WHEN a User selects a date range, THE Dashboard SHALL display only Debrief_Entity records with Meeting Date within the specified range
5. WHEN no Debrief_Entity records match the search or filter criteria, THE Dashboard SHALL display a message indicating no results found

### Requirement 5: Individual Debrief Viewing

**User Story:** As a User, I want to view complete debrief details on a dedicated page, so that I can review all meeting information in a structured format.

#### Acceptance Criteria

1. THE Detail_View SHALL display all fields of a Debrief_Entity in a structured, easy-to-read layout
2. THE Detail_View SHALL display Client Name, Meeting Date, Participants, Summary, Decisions Made, Action Items, and Risks/Concerns
3. THE Detail_View SHALL display Action Items with Description, Owner, and Due Date for each item
4. THE Detail_View SHALL be accessible via a unique URL containing the Debrief_Entity identifier
5. THE Detail_View SHALL use the dark navy, white, and warm amber color palette with clean sans-serif typography
6. THE Detail_View SHALL use card-based layouts with generous whitespace

### Requirement 6: Shareable URL Generation

**User Story:** As a User, I want to generate shareable links to debriefs, so that I can easily distribute meeting reports to colleagues.

#### Acceptance Criteria

1. THE Detail_View SHALL provide a "Copy Link" button
2. WHEN a User clicks the "Copy Link" button, THE Debriefly_System SHALL copy the unique URL for the current Debrief_Entity to the system clipboard
3. THE Debriefly_System SHALL generate unique URLs in the format that includes the Debrief_Entity identifier
4. WHEN a User navigates to a unique debrief URL, THE Debriefly_System SHALL display the Detail_View for the corresponding Debrief_Entity
5. WHEN a User successfully copies a link, THE Debriefly_System SHALL display a confirmation message

### Requirement 7: Email Sharing

**User Story:** As a User, I want to email debrief reports directly from the application, so that I can quickly share meeting outcomes with team members.

#### Acceptance Criteria

1. THE Detail_View SHALL provide an "Email Debrief" button
2. WHEN a User clicks the "Email Debrief" button, THE Debriefly_System SHALL display a modal dialog for email composition
3. THE email modal SHALL provide an input field for entering recipient email addresses
4. THE email modal SHALL support multiple recipient email addresses
5. WHEN a User submits the email modal, THE Backend_API SHALL send an email containing the formatted Debrief_Entity content to the specified recipients
6. THE email content SHALL include all Debrief_Entity fields formatted in a readable structure
7. WHEN an email is successfully sent, THE Debriefly_System SHALL display a confirmation message
8. IF email sending fails, THEN THE Debriefly_System SHALL display an error message to the User

### Requirement 8: RESTful API Endpoints

**User Story:** As a developer, I want well-defined RESTful API endpoints, so that the Flutter frontend can reliably interact with the backend.

#### Acceptance Criteria

1. THE Backend_API SHALL provide a POST endpoint for creating new Debrief_Entity records
2. THE Backend_API SHALL provide a GET endpoint for retrieving a single Debrief_Entity by identifier
3. THE Backend_API SHALL provide a GET endpoint for retrieving all Debrief_Entity records for a User
4. THE Backend_API SHALL provide a PUT endpoint for updating existing Debrief_Entity records
5. THE Backend_API SHALL provide a DELETE endpoint for removing Debrief_Entity records
6. WHEN a request is received, THE Backend_API SHALL validate the request payload against the Debrief_Entity schema
7. IF a request payload is invalid, THEN THE Backend_API SHALL return an error response with a descriptive message
8. WHEN a successful operation completes, THE Backend_API SHALL return the appropriate HTTP status code and response body

### Requirement 9: User Interface Design Consistency

**User Story:** As a User, I want a visually consistent and modern interface, so that the application is pleasant and easy to use.

#### Acceptance Criteria

1. THE Debriefly_System SHALL use dark navy as the dominant color throughout the interface
2. THE Debriefly_System SHALL use white and warm amber as accent colors
3. THE Debriefly_System SHALL use a clean sans-serif typeface similar to Inter for all text
4. THE Debriefly_System SHALL implement card-based layouts with generous whitespace
5. THE Debriefly_System SHALL apply smooth transitions between interface states
6. THE Debriefly_System SHALL maintain an ultra-minimal, modern SaaS aesthetic across all screens

### Requirement 10: Data Validation

**User Story:** As a User, I want the system to validate my input, so that I can ensure debrief data is complete and correctly formatted.

#### Acceptance Criteria

1. WHEN a User attempts to submit the Debrief_Form without a Client Name, THE Debriefly_System SHALL display a validation error message
2. WHEN a User attempts to submit the Debrief_Form without a Meeting Date, THE Debriefly_System SHALL display a validation error message
3. WHEN a User enters an Action_Item, THE Debriefly_System SHALL require Description, Owner, and Due Date fields
4. WHEN a User enters an invalid date format, THE Debriefly_System SHALL display a validation error message
5. THE Debriefly_System SHALL display validation error messages near the relevant form fields
6. WHEN all required fields are valid, THE Debriefly_System SHALL enable the form submission button
7. WHILE required fields are invalid or empty, THE Debriefly_System SHALL disable the form submission button
