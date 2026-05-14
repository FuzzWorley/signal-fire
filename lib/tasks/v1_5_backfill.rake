namespace :v1_5 do
  desc "Backfill host_profile slugs for any profile that doesn't have one"
  task backfill_host_slugs: :environment do
    without_slug = HostProfile.where(slug: nil).count
    HostProfile.where(slug: nil).find_each(&:save)
    puts "Done. #{without_slug} slugs generated. Total with slug: #{HostProfile.where.not(slug: nil).count}."
  end
  # totems.city_slug defaults to 'stpete' — no backfill needed
end
