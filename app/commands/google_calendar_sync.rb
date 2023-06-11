# frozen_string_literal: true

# Update the Google calendars of an account.
class GoogleCalendarSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(account_id)
    @account_id = account_id
  end

  def compute_id_sets(local_cals, remote_cals)
    local_calendar_ids  = local_cals.keys
    remote_calendar_ids = remote_cals.keys

    added_ids   = remote_calendar_ids - local_calendar_ids
    removed_ids = local_calendar_ids - remote_calendar_ids
    common_ids  = local_calendar_ids & remote_calendar_ids

    [added_ids, removed_ids, common_ids]
  end

  def create_new_calendars!(account, added_ids, remote_cals)
    added_ids.each do |added_id|
      logger.info("NEW CALENDAR FOR #{account.email}: #{added_id}")

      cal = GoogleCalendar.create_or_find_by!(google_id: added_id)

      cal_instance = account.calendar_instances.build
      cal_instance.from_raw(remote_cals[added_id], cal.id)
      cal_instance.save!
    end
  end

  def destroy_removed_calendars!(account, removed_ids, local_cals_instances)
    removed_ids.each do |google_id|
      logger.info("DEFUNCT CALENDAR FOR #{account.email}: #{google_id}")

      instances = local_cals_instances[google_id]
      next unless instances

      instances.each(&:destroy!)
    end
  end

  def update_modified_calendars!(account, common_ids, local_cals_instances, local_cals, remote_cals)
    common_ids.each do |google_id|
      remote_raw = remote_cals[google_id]

      instances = local_cals_instances[google_id]
      next unless instances

      instances.each do |instance|
        next if instance.to_raw.eql?(remote_raw)

        logger.info("MODIFIED CALENDAR FOR #{account.email}: #{google_id}")
        instance.from_raw(remote_raw, local_cals[google_id].id)
        instance.save!
      end
    end
  end

  def fetch_local_calendars(account)
    local_cals = account.calendars.index_by(&:google_id)
    local_cals_instances =
      account
      .calendar_instances
      .group_by { |inst| inst.calendar.google_id }
    [local_cals, local_cals_instances]
  end

  def actual_perform(account, client)
    logger.info("REFRESHING CALENDARS FOR: #{account.email} (id=#{account.id})")

    local_cals, local_cals_insts = fetch_local_calendars(account)

    remote_cals = client.fetch_calendars.last.index_by(&:id)

    added_ids, removed_ids, common_ids = compute_id_sets(local_cals, remote_cals)

    create_new_calendars!(account, added_ids, remote_cals)
    destroy_removed_calendars!(account, removed_ids, local_cals_insts)
    update_modified_calendars!(account, common_ids, local_cals_insts, local_cals, remote_cals)
  end

  def call
    account, client = account_and_client(@account_id, include_cals: true)

    return if account.blank?

    actual_perform(account, client)
  end
end
