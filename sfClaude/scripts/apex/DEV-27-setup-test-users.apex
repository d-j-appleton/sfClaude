/**
 * DEV-27: Persona Access Matrix Test Setup
 *
 * Creates four test users (one per persona), assigns the correct role and
 * permission set to each, then seeds a Venue, two Events, and two
 * Event_Registration__c records so the access matrix can be manually
 * verified in the org.
 *
 * Run via:
 *   sf apex run --file scripts/apex/DEV-27-setup-test-users.apex
 *
 * NOTE: Requires the following metadata to already be deployed:
 *   - Profile:  Charity Events Standard User
 *   - Roles:    CEO_Executive_Director, Executive_Trustee, Events_Manager,
 *               Fundraising_Officer, Volunteer_Coordinator
 *   - Perm sets: Events_Manager_Permissions, Fundraising_Officer_Permissions,
 *                Volunteer_Coordinator_Permissions, Executive_Trustee_Permissions
 *   - Custom objects: Venue__c, Event__c, Event_Registration__c,
 *                     Event_Ticket_Type__c
 */

// ─────────────────────────────────────────────────────────────────────────────
// 1. Look up required metadata records
// ─────────────────────────────────────────────────────────────────────────────

Profile baseProfile = [
    SELECT Id FROM Profile WHERE Name = 'Charity Events Standard User' LIMIT 1
];

Map<String, Id> roleMap = new Map<String, Id>();
for (UserRole r : [
    SELECT Id, DeveloperName FROM UserRole
    WHERE DeveloperName IN (
        'CEO_Executive_Director',
        'Executive_Trustee',
        'Events_Manager',
        'Fundraising_Officer',
        'Volunteer_Coordinator'
    )
]) {
    roleMap.put(r.DeveloperName, r.Id);
}

Map<String, Id> permSetMap = new Map<String, Id>();
for (PermissionSet ps : [
    SELECT Id, Name FROM PermissionSet
    WHERE Name IN (
        'Events_Manager_Permissions',
        'Fundraising_Officer_Permissions',
        'Volunteer_Coordinator_Permissions',
        'Executive_Trustee_Permissions'
    )
]) {
    permSetMap.put(ps.Name, ps.Id);
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Create (or upsert) the four test users
// ─────────────────────────────────────────────────────────────────────────────

String uniqueSuffix = String.valueOf(DateTime.now().getTime());
String orgDomain    = UserInfo.getUserName().substringAfter('@');

List<User> testUsers = new List<User>{
    new User(
        FirstName       = 'Test',
        LastName        = 'EventsManager',
        Alias           = 'tevtmgr',
        Email           = 'test.eventsmanager+' + uniqueSuffix + '@' + orgDomain,
        Username        = 'test.eventsmanager+' + uniqueSuffix + '@' + orgDomain,
        ProfileId       = baseProfile.Id,
        UserRoleId      = roleMap.get('Events_Manager'),
        TimeZoneSidKey  = 'Europe/London',
        LocaleSidKey    = 'en_GB',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8'
    ),
    new User(
        FirstName       = 'Test',
        LastName        = 'FundraisingOfficer',
        Alias           = 'tfundoff',
        Email           = 'test.fundraisingofficer+' + uniqueSuffix + '@' + orgDomain,
        Username        = 'test.fundraisingofficer+' + uniqueSuffix + '@' + orgDomain,
        ProfileId       = baseProfile.Id,
        UserRoleId      = roleMap.get('Fundraising_Officer'),
        TimeZoneSidKey  = 'Europe/London',
        LocaleSidKey    = 'en_GB',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8'
    ),
    new User(
        FirstName       = 'Test',
        LastName        = 'VolunteerCoordinator',
        Alias           = 'tvolcrd',
        Email           = 'test.volunteercoordinator+' + uniqueSuffix + '@' + orgDomain,
        Username        = 'test.volunteercoordinator+' + uniqueSuffix + '@' + orgDomain,
        ProfileId       = baseProfile.Id,
        UserRoleId      = roleMap.get('Volunteer_Coordinator'),
        TimeZoneSidKey  = 'Europe/London',
        LocaleSidKey    = 'en_GB',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8'
    ),
    new User(
        FirstName       = 'Test',
        LastName        = 'ExecutiveTrustee',
        Alias           = 'texetrst',
        Email           = 'test.executivetrustee+' + uniqueSuffix + '@' + orgDomain,
        Username        = 'test.executivetrustee+' + uniqueSuffix + '@' + orgDomain,
        ProfileId       = baseProfile.Id,
        UserRoleId      = roleMap.get('Executive_Trustee'),
        TimeZoneSidKey  = 'Europe/London',
        LocaleSidKey    = 'en_GB',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8'
    )
};

insert testUsers;

// Map last-name → User for convenience
Map<String, User> userByLastName = new Map<String, User>();
for (User u : testUsers) {
    userByLastName.put(u.LastName, u);
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Assign permission sets
// ─────────────────────────────────────────────────────────────────────────────

List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>{
    new PermissionSetAssignment(
        AssigneeId    = userByLastName.get('EventsManager').Id,
        PermissionSetId = permSetMap.get('Events_Manager_Permissions')
    ),
    new PermissionSetAssignment(
        AssigneeId    = userByLastName.get('FundraisingOfficer').Id,
        PermissionSetId = permSetMap.get('Fundraising_Officer_Permissions')
    ),
    new PermissionSetAssignment(
        AssigneeId    = userByLastName.get('VolunteerCoordinator').Id,
        PermissionSetId = permSetMap.get('Volunteer_Coordinator_Permissions')
    ),
    new PermissionSetAssignment(
        AssigneeId    = userByLastName.get('ExecutiveTrustee').Id,
        PermissionSetId = permSetMap.get('Executive_Trustee_Permissions')
    )
};

insert assignments;

// ─────────────────────────────────────────────────────────────────────────────
// 4. Seed a Venue
// ─────────────────────────────────────────────────────────────────────────────

Venue__c venue = new Venue__c(
    Name                  = 'DEV-27 Test Venue',
    Street__c             = '10 Test Street',
    City__c               = 'London',
    State__c              = 'England',
    PostalCode__c         = 'EC1A 1BB',
    Country__c            = 'UK',
    Capacity__c           = 200,
    Indoor_Outdoor__c     = 'Indoor',
    Accessibility_Notes__c = 'Step-free access via main entrance'
);
insert venue;

// ─────────────────────────────────────────────────────────────────────────────
// 5. Seed two Events (owned by the Events Manager test user)
//    - One Draft event (not visible via sharing rule)
//    - One Published event (visible to CEO_Executive_Director subtree via sharing rule)
// ─────────────────────────────────────────────────────────────────────────────

Id eventsManagerId = userByLastName.get('EventsManager').Id;

List<Event__c> events = new List<Event__c>{
    new Event__c(
        Name                = 'DEV-27 Draft Charity Gala',
        Event_Type__c       = 'Fundraiser',
        Status__c           = 'Draft',
        Start_DateTime__c   = DateTime.now().addDays(30),
        End_DateTime__c     = DateTime.now().addDays(30).addHours(4),
        Venue__c            = venue.Id,
        Primary_Organizer__c = eventsManagerId,
        Expected_Attendees__c = 100,
        Target_Amount__c    = 5000,
        Is_Public__c        = false,
        OwnerId             = eventsManagerId
    ),
    new Event__c(
        Name                = 'DEV-27 Published Summer Fete',
        Event_Type__c       = 'Community',
        Status__c           = 'Published',
        Start_DateTime__c   = DateTime.now().addDays(60),
        End_DateTime__c     = DateTime.now().addDays(60).addHours(6),
        Venue__c            = venue.Id,
        Primary_Organizer__c = eventsManagerId,
        Expected_Attendees__c = 150,
        Target_Amount__c    = 2500,
        Is_Public__c        = true,
        OwnerId             = eventsManagerId
    )
};

insert events;

Event__c draftEvent     = events[0];
Event__c publishedEvent = events[1];

// ─────────────────────────────────────────────────────────────────────────────
// 6. Seed Event Ticket Types
// ─────────────────────────────────────────────────────────────────────────────

List<Event_Ticket_Type__c> ticketTypes = new List<Event_Ticket_Type__c>{
    new Event_Ticket_Type__c(
        Name          = 'General Admission — Summer Fete',
        Event__c      = publishedEvent.Id,
        Ticket_Type__c = 'General Admission',
        Price__c      = 10,
        Capacity__c   = 100,
        Is_Active__c  = true
    ),
    new Event_Ticket_Type__c(
        Name          = 'Volunteer — Summer Fete',
        Event__c      = publishedEvent.Id,
        Ticket_Type__c = 'Volunteer',
        Price__c      = 0,
        Capacity__c   = 50,
        Is_Active__c  = true
    )
};

insert ticketTypes;

Event_Ticket_Type__c generalTicket   = ticketTypes[0];
Event_Ticket_Type__c volunteerTicket = ticketTypes[1];

// ─────────────────────────────────────────────────────────────────────────────
// 7. Seed two Registrations on the Published event
//    - One General Admission (editable only by Events Manager / Fundraising Officer)
//    - One Volunteer (editable by Volunteer Coordinator)
// ─────────────────────────────────────────────────────────────────────────────

// Use a real Contact if one exists, otherwise proceed without
Id contactId = null;
List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
if (!contacts.isEmpty()) {
    contactId = contacts[0].Id;
}

List<Event_Registration__c> registrations = new List<Event_Registration__c>{
    new Event_Registration__c(
        Event__c                 = publishedEvent.Id,
        Registration_Date__c     = Date.today(),
        Registration_Status__c   = 'Confirmed',
        Registration_Source__c   = 'Online',
        Ticket_Type_Record__c    = generalTicket.Id,
        Ticket_Price__c          = 10,
        Special_Requirements__c  = 'None',
        Consent_to_Contact__c    = true,
        Contact__c               = contactId
    ),
    new Event_Registration__c(
        Event__c                 = publishedEvent.Id,
        Registration_Date__c     = Date.today(),
        Registration_Status__c   = 'Confirmed',
        Registration_Source__c   = 'In Person',
        Ticket_Type_Record__c    = volunteerTicket.Id,
        Ticket_Price__c          = 0,
        Special_Requirements__c  = 'Parking needed',
        Consent_to_Contact__c    = false,
        Contact__c               = contactId
    )
};

insert registrations;

// ─────────────────────────────────────────────────────────────────────────────
// 8. Output summary for verification
// ─────────────────────────────────────────────────────────────────────────────

System.debug('=== DEV-27 Test Data Setup Complete ===');
System.debug('Profile used: Charity Events Standard User (Id: ' + baseProfile.Id + ')');
System.debug('');
System.debug('Test Users:');
for (User u : testUsers) {
    System.debug('  [' + u.LastName + '] Id=' + u.Id + '  Username=' + u.Username);
}
System.debug('');
System.debug('Venue: ' + venue.Name + ' (Id: ' + venue.Id + ')');
System.debug('Events:');
System.debug('  Draft     – ' + draftEvent.Name     + ' (Id: ' + draftEvent.Id     + ')');
System.debug('  Published – ' + publishedEvent.Name + ' (Id: ' + publishedEvent.Id + ')');
System.debug('Ticket Types:');
System.debug('  General Admission Id: ' + generalTicket.Id);
System.debug('  Volunteer         Id: ' + volunteerTicket.Id);
System.debug('Registrations:');
System.debug('  General Admission reg Id: ' + registrations[0].Id);
System.debug('  Volunteer         reg Id: ' + registrations[1].Id);
System.debug('');
System.debug('=== Manual Verification Checklist ===');
System.debug('Log in as each test user and confirm:');
System.debug('  Events Manager       – CRUD on Events, Registrations; Read-only on Opportunity');
System.debug('  Fundraising Officer  – Read/Edit Events (Target_Amount__c only editable field);');
System.debug('                         Read-only Registrations; Create/Edit Opportunities');
System.debug('  Volunteer Coordinator – Read-only Events; Read/Create/Edit Registrations');
System.debug('                          (only Volunteer type via validation rule);');
System.debug('                          cannot edit Ticket_Price__c');
System.debug('  Executive / Trustee  – Read + ViewAll on Events and Registrations; no edit');
System.debug('  Sharing rule         – Published event visible to Executive / Trustee via');
System.debug('                          Share_Published_Events criteria-based rule');
