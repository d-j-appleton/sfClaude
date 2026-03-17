# High Level Design Document (sfClaude)

<!-- METADATA -->
| Field | Value |
|---|---|
| **File Name** | High Level Design Document (sfClaude) |
| **Type** | Google Doc (`application/vnd.google-apps.document`) |
| **Drive ID** | `1gm-w4q8IQVYUQlRkpKXdgPh6oajXK3pN-Red_P5wEdo` |
| **Last Modified** | 2026-03-14T00:21:32.167Z |
| **Cached** | 2026-03-14 |

---

## Salesforce Charity Events Management Solution

*High-level design document for demonstration purposes*

---

## Introduction

The Salesforce Charity Events Management Solution is a purpose-built platform designed to centralise and streamline the end-to-end management of fundraising and charity events. It enables organisations to plan, publish, and track events of varying types — from gala dinners and fun runs to online webinars and community days — within a single, governed system.

At its core, the solution manages the full event lifecycle from initial drafting through approval, publication, completion, and archival. It captures attendee registrations with granular detail including ticket type, special requirements, and attendance status, while linking financial outcomes directly to events through an integrated donations model. This gives the organisation a clear, real-time picture of both engagement and fundraising impact for every event.

A structured approval process ensures that high-value or high-risk events receive appropriate governance oversight before being published, with automated notifications keeping organisers and approvers informed at each stage. Supporting automation handles capacity validation, attendee reminders, and status management, reducing manual effort and the risk of administrative error.

Access to the system is controlled through a role-based security model, ensuring that staff see and can act on only the data relevant to their responsibilities — whether that is an Events Manager running registrations, a Fundraising Officer managing sponsorships, or an Executive reviewing performance dashboards.

The user experience is delivered through a custom Lightning application featuring a visual events calendar, personalised event views, and key performance metrics. Purpose-built components allow staff to register attendees quickly and monitor event health — capacity, donations against target, and registration volumes — at a glance.

The solution is intentionally designed to be extensible, with a clear path to adding public self-registration via Experience Cloud and payment gateway integration as the organisation's needs grow.

---

## 1. Overview

The goal is to design a compact but realistic Salesforce solution to manage charity and fundraising events. It should be rich enough to showcase:

- **Data model:** Events, attendees, registrations, donations.
- **Security model:** Roles, sharing, and record-level access.
- **Automation:** Approvals, flows, and notifications.
- **User experience:** Standard UI, custom Lightning pages, and at least one Lightning Web Component (LWC).
- **Sample data:** To illustrate how the system works end-to-end.

This is intentionally scoped to be implementable as a demo project, not a full enterprise product.

---

## 2. Business Objectives and Scope

### 2.1 Objectives

- **Centralise event management:** Plan, publish, and track charity events in one place.
- **Manage attendees and registrations:** Capture who is coming, their preferences, and their relationship to the charity.
- **Track fundraising impact:** Link events to donations and basic financial outcomes.
- **Provide clear visibility:** Calendar-style overview of upcoming events and key metrics.
- **Support governance:** Simple approval for high-value or high-risk events.

### 2.2 In Scope

- Event lifecycle: `Draft → Approved → Published → Completed → Archived`
- Event registration: Manual and self-service (via Experience Cloud optional extension).
- Attendee management: Contact-level data, attendance status, special requirements.
- Donations linkage: Simple association of donations to events.
- Security model: Profiles/permission sets, role-based access, sharing rules.
- Automation: Approvals, flows, email alerts, basic validation.
- UI:
  - App home page with calendar and KPIs.
  - Event record page with related lists and custom components.
  - LWC for calendar and quick registration.

### 2.3 Out of Scope (for this demo)

- Complex payment gateway integration.
- Full grant management or volunteer scheduling.
- Deep marketing automation (e.g., journeys, campaigns).

---

## 3. High-Level Architecture

### 3.1 Logical Components

- **Salesforce core:**
  - Custom objects for Event, Event Registration, Event Session (optional), Event Venue.
  - Standard objects: Account, Contact, Opportunity (for donations).
- **Automation layer:**
  - Record-triggered Flows for status changes, email notifications, and data consistency.
  - Approval Process for event approval.
- **Presentation layer:**
  - Custom Lightning App: "Charity Events".
  - Lightning App Home page with:
    - Event calendar (LWC).
    - "My Events" list.
    - Key metrics (e.g., total attendees, total donations).
  - Event record page with:
    - Event summary.
    - Related registrations and donations.
    - LWC for quick attendee registration.
- **Optional extension:**
  - Experience Cloud site for public event listing and self-registration (described but not required to build).

---

## 4. Data Model

### 4.1 Core Custom Objects

#### 4.1.1 `Event__c`

**Purpose:** Represents a single fundraising or charity event.

| Field | Type | Notes |
|---|---|---|
| Name | Text | e.g., "Spring Charity Gala 2026" |
| Event_Type__c | Picklist | Gala, Fun Run, Online Webinar, Community Day, Other |
| Start_DateTime__c / End_DateTime__c | DateTime | |
| Status__c | Picklist | Draft, Pending Approval, Approved, Published, Completed, Cancelled |
| Target_Amount__c | Currency | |
| Expected_Attendees__c | Number | |
| Actual_Attendees__c | Roll-up | From registrations |
| Total_Donations__c | Roll-up | From Opportunities |
| Venue__c | Lookup | To Venue__c |
| Primary_Organizer__c | Lookup | To User |
| Description__c | Long Text | |
| Is_Public__c | Checkbox | For public listing |
| Risk_Level__c | Picklist | Low, Medium, High |

#### 4.1.2 `Event_Registration__c`

**Purpose:** Links an attendee (Contact) to an Event.

| Field | Type | Notes |
|---|---|---|
| Name | Auto-number | e.g., REG-000123 |
| Event__c | Lookup | To Event__c |
| Contact__c | Lookup | To Contact |
| Registration_Status__c | Picklist | Registered, Waitlisted, Cancelled, Attended, No Show |
| Registration_Source__c | Picklist | Internal, Website, Phone, Email, Partner |
| Special_Requirements__c | Long Text | Dietary, accessibility |
| Ticket_Type__c | Picklist | Standard, VIP, Sponsor, Volunteer |
| Ticket_Price__c | Currency | |
| Check_In_Time__c | DateTime | |
| Consent_to_Contact__c | Checkbox | |

#### 4.1.3 `Venue__c`

**Purpose:** Stores event locations.

| Field | Type | Notes |
|---|---|---|
| Name | Text | |
| Address__c | Text Area | Or standard address fields |
| Capacity__c | Number | |
| Indoor_Outdoor__c | Picklist | Indoor, Outdoor, Hybrid |
| Accessibility_Notes__c | Long Text | |

#### 4.1.4 `Event_Session__c` *(optional, for multi-session events)*

**Purpose:** Breaks an event into sessions (e.g., morning run, afternoon concert).

| Field | Type | Notes |
|---|---|---|
| Name | Text | |
| Event__c | Lookup | To Event__c |
| Start_DateTime__c / End_DateTime__c | DateTime | |
| Speaker__c | Text or Lookup | To Contact |
| Capacity__c | Number | |

### 4.2 Relationships to Standard Objects

- **Contact:** Related to Event_Registration__c (one Contact → many registrations). Can be used to see a supporter's full event history.
- **Account:** Used for corporate sponsors or partner organisations. Optional lookup on Event__c (e.g., `Sponsored_By__c`).
- **Opportunity (Donation):** `Event__c` lookup to Event__c to attribute donations to events. `Donation_Type__c` picklist: Event Ticket, Event Sponsorship, General Donation.

---

## 5. Sample Data Setup

### 5.1 Sample Events

| Event Name | Type | Status | Start | End | Target £ | Venue |
|---|---|---|---|---|---|---|
| Spring Charity Gala 2026 | Gala | Published | 2026-04-10 19:00 | 2026-04-10 23:00 | 50,000 | Grand Hall |
| Riverside Fun Run | Fun Run | Approved | 2026-05-15 09:00 | 2026-05-15 13:00 | 10,000 | Riverside Park |
| Online Donor Briefing | Webinar | Draft | 2026-03-25 18:00 | 2026-03-25 19:30 | 5,000 | Virtual (Online) |

### 5.2 Sample Venues

| Venue Name | Capacity | Type |
|---|---|---|
| Grand Hall | 300 | Indoor |
| Riverside Park | 500 | Outdoor |
| Virtual (Online) | 1000 | Hybrid |

### 5.3 Sample Contacts and Registrations

**Contacts:**
- Alice Donor – long-term supporter.
- Ben Runner – new supporter, interested in sports events.
- Cara Sponsor – contact at corporate sponsor.

**Registrations:**

| Registration | Event | Contact | Status | Ticket Type | Price |
|---|---|---|---|---|---|
| REG-0001 | Spring Charity Gala | Alice Donor | Registered | VIP | 250 |
| REG-0002 | Riverside Fun Run | Ben Runner | Registered | Standard | 25 |
| REG-0003 | Spring Charity Gala | Cara Sponsor | Registered | Sponsor | 0 |

### 5.4 Sample Donations

| Opportunity Name | Amount | Stage | Event | Account |
|---|---|---|---|---|
| Spring Gala – Alice VIP Ticket | 250 | Closed Won | Spring Charity Gala | (Alice's HH) |
| Spring Gala – Corporate Sponsor | 10,000 | Closed Won | Spring Charity Gala | Cara's Company |
| Fun Run – Ben Registration | 25 | Closed Won | Riverside Fun Run | (Ben's HH) |

---

## 6. Security Model and Personas

### 6.1 Personas

| Persona | Responsibilities | Access |
|---|---|---|
| Events Manager | Create and manage events, oversee registrations, run reports | Full CRUD on Event__c, Event_Registration__c, Venue__c; read on Opportunities; manage approvals |
| Fundraising Officer | Manage high-value events, sponsorships, and donations | Read/Update on Event__c; CRUD on Opportunities linked to events; read registrations |
| Volunteer Coordinator | Manage volunteer attendees and logistics | Read on Event__c; CRUD on Event_Registration__c (volunteer ticket types); read Venues |
| Executive / Trustee | Approve high-risk or high-value events; view KPIs | Read-only on all event data; approval rights; access to dashboards |
| System Administrator | Configuration, security, and maintenance | Full |

### 6.2 Profiles and Permission Sets

- **Profiles:**
  - *Charity Events Standard User:* Base profile with read access to core objects.
- **Permission sets:**
  - *Events Manager Permissions:* Elevated access to create/edit events and venues.
  - *Fundraising Officer Permissions:* Access to donation-related fields and reports.
  - *Volunteer Coordinator Permissions:* Extended access to registrations.

### 6.3 Sharing Model

- **Org-wide defaults:**
  - `Event__c`: Private (or Public Read Only, depending on size of org).
  - `Event_Registration__c`: Controlled by parent (`Event__c`).
  - `Venue__c`: Public Read Only.
- **Role hierarchy:** Events Managers and Fundraising Officers above Volunteer Coordinators.
- **Sharing rules:**
  - Share all Approved/Published events read-only with all internal users.
  - Share events where `Primary_Organizer__c` = current user with that user (if OWD is Private).

---

## 7. Automation and Approvals

### 7.1 Event Approval Process

- **Trigger:** `Event__c.Status__c` changed from `Draft` to `Pending Approval`.
- **Entry criteria:** `Risk_Level__c = "High"` OR `Target_Amount__c > 20,000`.
- **Approvers:**
  - First level: Events Manager.
  - Second level: Executive / Trustee (for high-risk events).
- **Actions:**
  - On submission: Lock record, send email to approvers.
  - On approval: Set `Status__c = "Approved"`; unlock record.
  - On rejection: Set `Status__c = "Draft"`; notify `Primary_Organizer__c`.

### 7.2 Flows

- **Record-triggered Flow on `Event__c`** (After save):
  - If `Status__c = "Completed"`, calculate `Actual_Attendees__c` from related registrations.
  - If `Is_Public__c = true` and `Status__c = "Approved"`, auto-set `Status__c = "Published"`.
- **Record-triggered Flow on `Event_Registration__c`** (Before save):
  - If `Ticket_Price__c` is blank, default based on `Ticket_Type__c` and `Event_Type__c`.
  - Validate Venue capacity (count registrations vs `Venue__c.Capacity__c`).
- **Scheduled Flow** (Daily): Send reminder emails to registered attendees 3 days before event start.

### 7.3 Email Alerts and Templates

- Event Registration Confirmation
- Event Reminder
- Event Approval Request

---

## 8. User Interface Design

### 8.1 Charity Events Lightning App

**Navigation items:** Home, Events, Registrations, Venues, Donations, Reports & Dashboards.

### 8.2 Home Page Layout

- **Events Calendar LWC:** Month/week view of `Event__c` records.
- **My Upcoming Events list:** Filtered list view where `Primary_Organizer__c` = current user.
- **KPI tiles:**
  - Total events this quarter.
  - Total expected attendees.
  - Total donations from events this year.
- **Quick Actions:** "Create New Event", "Create Venue".

### 8.3 Event Record Page Layout

- **Header:** Key fields (Status, Start/End, Target_Amount__c, Total_Donations__c).
- **Tabs:**
  - *Details:* Core event fields.
  - *Registrations:* Related list of Event_Registration__c.
  - *Donations:* Related Opportunities.
  - *Sessions:* Related Event_Session__c (if used).
  - *Insights:* Embedded report chart (e.g., registrations by ticket type).
- **Custom components:**
  - Quick Registration LWC: Add a new registration inline.
  - Event Summary LWC (optional): Shows key metrics and warnings (e.g., capacity nearly reached).

---

## 9. Lightning Web Components (LWCs)

### 9.1 Events Calendar LWC

**Purpose:** Visual calendar of events on the Home page.

- **Key features:**
  - Month/week toggle.
  - Colour-coding by `Event_Type__c` or `Status__c`.
  - Tooltip with event name, date/time, venue, and current registrations.
  - Click-through to Event record.
- **Data source:** Apex controller querying `Event__c` with date range filters.
- **Config options (via design file):**
  - Default view (month/week).
  - Filter by `Event_Type__c`.
  - Show only Published events.

### 9.2 Quick Registration LWC

**Purpose:** Allow users to quickly add an attendee to an event from the Event record page.

- **Key features:**
  - Search existing Contact or create new Contact inline.
  - Select `Ticket_Type__c` and auto-calculate `Ticket_Price__c` (via Flow or client logic).
  - Save `Event_Registration__c` and refresh related list.
- **Data source:**
  - Lightning Data Service for create/update.
  - `Event__c` Id passed via `@api recordId`.

### 9.3 Optional: Event Metrics LWC

**Purpose:** Show real-time metrics on the Event record.

- **Key features:**
  - Registrations vs capacity.
  - Donations vs target.
  - Simple visual indicators (e.g., progress bars).

---

## 10. Reporting and Dashboards

- **Reports:**
  - Events by Status and Type.
  - Registrations by Event and Ticket Type.
  - Donations by Event.
  - Attendee history by Contact.
- **Dashboards — Fundraising Events Overview:**
  - Total donations by event.
  - Upcoming events by month.
  - Registration breakdown by ticket type.

---

## 11. Non-Functional Considerations

| Concern | Approach |
|---|---|
| Performance | Limit calendar queries to a date range; use indexed fields for filters (`Start_DateTime__c`, `Status__c`) |
| Scalability | Data model supports many events and registrations; can later extend to campaigns, volunteers, etc. |
| Auditability | Field history tracking on key fields (`Status__c`, `Target_Amount__c`, `Risk_Level__c`) |
| Extensibility | Easy to plug in Experience Cloud for public registration; can integrate payment providers via Apex or external services |

---

## 12. Implementation Phases (for Demo)

| Phase | Focus | Key Tasks |
|---|---|---|
| Phase 1 | Core data model and sample data | Create custom objects and fields; configure relationships and page layouts; load sample data |
| Phase 2 | Security and automation | Configure profiles, permission sets, sharing rules; implement Event approval process; build Flows |
| Phase 3 | UI and LWCs | Build Charity Events Lightning App and Home page; implement Events Calendar LWC; implement Quick Registration LWC; configure reports and dashboards |
| Phase 4 | Polishing for demo | Add sample email templates; add validation rules (e.g., `End_DateTime__c > Start_DateTime__c`); prepare demo scripts |
