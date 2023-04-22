# frozen_string_literal: true

task stats: :"omakase:stats"

namespace :omakase do
  task :stats do
    require "rails/code_statistics"
    new_categories = [
      ["App Libraries", "app/lib"],
      ["Commands", "app/commands"],
    ]
    STATS_DIRECTORIES.append(*new_categories)

    STATS_DIRECTORIES.sort! do |a, b|
      spec_result =
        case [a[0].include?("spec"), b[0].include?("spec")]
        when [true, false] then 1
        when [false, true] then -1
        else 0
        end

      [spec_result, a[0] <=> b[0]].reject(&:zero?).first || 0
    end
  end
end
