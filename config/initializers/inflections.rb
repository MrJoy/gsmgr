# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )

  # N.B. You may need to add an entry to the CustomTransform setting for the RSpec/FilePath in
  # .rubocop.yml if adding an acronym here, as RSpec doesn't use the Rails inflector.
  inflect.acronym("GSuite")
  inflect.acronym("GMail")
  # inflect.acronym("ID") # This horks Avo.  Boo.
  inflect.acronym("JSON")
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
