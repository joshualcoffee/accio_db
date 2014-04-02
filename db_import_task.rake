namespace :db do
  desc "Retrieve Database via Heroku CLI"

  task :import => :environment do
    app = ENV['app']
    if app.blank?
      abort( "You did not specify the correct heroku app, please specify a heroku app"+ "\n" + "EXAMPLE: foreman run rake db:import app=<APP>" )
      
    end
    #capture newest version of the app database
    puts "capturing database"
    `heroku pgbackups:capture --expire --app #{app}`
    url = `heroku pgbackups:url --app #{app}`
    puts "getting database #{url}"

    name = "#{Rails.root}/db/#{Time.now.to_i}.dump"
    `curl -o #{name} \"#{url}\"`
    
    database = Rails.configuration.database_configuration['development']['database'] 
    puts "dropping and restoring database"
    Rake::Task["db:reset"].invoke
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d  #{database} #{name}`
  end
end