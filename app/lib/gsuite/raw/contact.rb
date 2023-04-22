# frozen_string_literal: true

# A simplified representation of a contact, as returned by Google.
GSuite::Raw::Contact =
  Struct.new(
    :id,
    :primary_email,
    :all_emails,
    :display_name,
    :display_name_last_first,
    :family_name,
    :middle_name,
    :given_name
  ) do
    # rubocop:disable Metrics/ParameterLists
    def initialize(
      id:,
      primary_email:,
      all_emails:              nil,
      display_name:            nil,
      display_name_last_first: nil,
      family_name:             nil,
      middle_name:             nil,
      given_name:              nil
    )
      super(id,

            primary_email,
            all_emails || [],

            display_name,
            display_name_last_first,
            family_name,
            middle_name,
            given_name)
    end
    # rubocop:enable Metrics/ParameterLists

    def self.from_google(google_contact)
      primary_email, all_emails = extract_emails_from(google_contact)

      name = google_contact.names&.first
      GSuite::Raw::Contact.new(
        id:                      google_contact.resource_name.split("/").last,

        primary_email:,
        all_emails:,

        display_name:            name&.display_name,
        display_name_last_first: name&.display_name_last_first,
        family_name:             name&.family_name,
        middle_name:             name&.middle_name,
        given_name:              name&.given_name
      )
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def self.extract_emails_from(google_contact)
      primary_email = google_contact.email_addresses&.find { |em| em.metadata.primary }&.value
      all_emails    = google_contact.email_addresses&.map(&:value)&.uniq || []

      primary_email&.downcase!
      all_emails.map!(&:downcase)

      [primary_email, all_emails]
    end
    # rubocop:enable Metrics/PerceivedComplexity
  end
