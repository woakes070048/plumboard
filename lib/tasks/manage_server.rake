namespace :manage_server do

  # resets tables for testing
  task :reset_users => :environment do
    users = User.where "email not like '%pixiboard.com'"
    users.each do |usr|
      puts "Deleting user #{usr.name}"
      usr.destroy
    end
  end

  # resets tables for testing
  task :reset_tables => :environment do
    Transaction.destroy_all
    Listing.destroy_all
    TempListing.destroy_all
    BankAccount.destroy_all
    CardAccount.destroy_all
    Invoice.destroy_all
    PixiPost.destroy_all
  end

  # remove old pixis
  task :close_expired_pixis => :environment do
    Listing.close_pixis
    User.find_each { |usr| User.reset_counters(usr.id, :active_listings) }
  end

  # pick fb sweepstakes winner
  task :pick_sweepstakes_winner => :environment do
    entrants = User.where(fb_user: true).order("RAND()")
    puts "The winner is #{entrants.first.name}. Email: #{entrants.first.email}"
  end

  # pick drawing winner
  task :pick_drawing_winner => :environment do
    val = ['abp', 'dr', 'fr', 'bpx', 'spx', 'ppx']
    entrants = UserPixiPoint.where(code: val).where("created_at >= ? AND created_at < ?", '2014-09-02'.to_date, '2014-10-15'.to_date).order("RAND()")
    puts "The winner is #{entrants.first.user.name}. Email: #{entrants.first.user.email}"
  end

  # send expiring pixi notices
  task :send_expiring_pixi_notices, [:arg1] => [:environment] do |t, args|
    a = args[:arg1].to_i
    pixis = Listing.soon_expiring_pixis(a)
    if !pixis.nil?
      users = User.where(id: pixis.all.map(&:seller_id))
      users.each do |user|
        UserMailer.send_expiring_pixi_notice(args.arg1, user).deliver_later
      end
    end
  end
  
  # send expiring draft pixi notices
  task :send_expiring_draft_pixi_notices, [:arg1] => [:environment] do|t, args|
    a = args[:arg1].to_i
    pixis = TempListing.soon_expiring_pixis(a, ['edit', 'new'])
    if !pixis.nil?
      pixis.each do |pixi|
        UserMailer.send_expiring_pixi_notice(args.arg1, pixi).deliver_later
      end
    end
  end	

  task :send_invoiceless_pixi_notices => :environment do
    listings = Listing.invoiceless_pixis
    unless listings.blank?
      listings.each do |listing|
        UserMailer.send_invoiceless_pixi_notice(listing).deliver_later
      end
    end
  end

  task :send_unpaid_old_invoice_notices => :environment do
    invoices = Invoice.unpaid_old_invoices
    unless invoices.blank?
      invoices.each do |invoice|
        UserMailer.send_unpaid_old_invoice_notice(invoice).deliver_later
      end
    end
  end

  task :cleanup_guests => :environment do
    User.where(guest: :true).where("created_at < ?", 1.week.ago).destroy_all
  end

  task :reprocess_listing_images => :environment do
    Listing.active.find_each do |pixi|
      pixi.pictures.each do |pic|
        %w(medium large).each do |style|
          pic.photo.reprocess! style.to_sym
	end
      end
    end
  end

  task :reprocess_user_images => :environment do
    User.active.find_each do |user|
      user.pictures.each do |pic|
        %w(tiny small thumb medium cover).each do |style|
          pic.photo.reprocess!(style.to_sym)
	end
      end
    end
  end

  task :reprocess_category_images => :environment do
    Category.all.each do |category|
      category.pictures.each do |pic|
        %w(thumb large).each do |style|
          pic.photo.reprocess!(style.to_sym)
	end
      end
    end
  end

  task :load_news_feeds => :environment do
    LoadNewsFeed.read_feeds
  end

  # used to migrate 1.0 users to 2.0 business accounts
  task :setup_bus_accts => :environment do
    CSV.foreach(Rails.root.join('db', 'pxb_bus_acct_071415.csv'), :headers => true) do |row|
      if user = User.where(email: row[0]).first 
        user.business_name, user.user_type_code = row[1], 'BUS'

        # save user
        if user.save 
          puts "Saved user #{user.business_name}"
        else
          puts user.errors.first
        end
      end
    end
  end

  task :import_job_feed => :environment do
    LoadNewsFeed.import_job_feed
  end

  task :update_buy_now => :environment do
    Listing.update_buy_now
    TempListing.update_buy_now
  end

  task :update_fulfillment_types => :environment do
    Listing.update_fulfillment_types
    TempListing.update_fulfillment_types
  end

  task :set_delivery_preferences => :environment do
    business_user_ids = User.where(user_type_code: 'BUS').pluck(:id)
    preferences = Preference.where(user_id: business_user_ids)
    defaults = { ship_amt: 10.0, sales_tax: 8.25, fulfillment_type_code: "'P'" }
    defaults.each do |field, value|
      preferences.where(field => nil).update_all("#{field} = #{value}")
    end
  end

  task :set_card_counters => :environment do
    User.find_each { |usr| User.reset_counters(usr.id, :active_card_accounts) }
  end

  task :set_ship_address_user_ids => :environment do
    ShipAddress.where(user_id: nil).find_each do |ship_addr|
      ship_addr.update_attribute(:user_id, User.find_by_email(ship_addr.recipient_email).id)
    end
  end

  task :set_invoice_fulfillment_type => :environment do
    data = Invoice.where('ship_amt is not null and ship_amt > ?', 0).where('created_at < ?', Date.today+6.months)
    data.find_each { |inv| InvoiceProcessor.new(inv).process_shipping }
  end

  task :run_upgrade_tasks => :environment do
    Rake::Task['manage_server:set_invoice_fulfillment_type'].invoke
  end
end
