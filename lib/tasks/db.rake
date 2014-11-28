namespace :db do

  desc "Synch mongodb; defaults: host_from: '10.0.105.15:27017', host_to: '127.0.0.1:27017', db_name: 'crawler'"
  task :mongodb_synch, [:host_from, :host_to, :db_name] => :environment do |t, args|
    require 'fileutils'
    defaults = { host_from: "10.0.105.15:27017", host_to: "127.0.0.1:27017", db_name: "crawler" }

    host_from = args.host_from.nil? || args.host_from.empty? ? defaults[:host_from]  : args.host_from
    host_to = args.host_to.nil? || args.host_to.empty? ? defaults[:host_to]  : args.host_to
    db_name = args.db_name.nil? || args.db_name.empty? ? defaults[:db_name]  : args.db_name

    dumps_path = "/var/backups/tender-crawler/mongodb/updater/"
    dump_name_template = "mongodb_crawler_"
    FileUtils.mkdir_p(dumps_path)

    dump_name = dump_name_template + Time.now.getutc.to_i.to_s
    full_dump_path = dumps_path + dump_name
    FileUtils.mkdir_p(full_dump_path)

    print "FROM: [#{host_from}]\nTO: [#{host_to}]\nDB: [#{db_name}]\n Enter 'yes' to continue: "
    abort "Exit" unless ['yes', 'Yes', 'y', 'Y'].include?(STDIN.gets.chomp)

    puts "\n\n################ Download dump ################\n\n"
    system("mongodump --host #{host_from} --db #{db_name} --out #{full_dump_path}")

    puts "\n\n################ Update database ################\n\n"
    system("mongorestore --host #{host_to} --drop #{full_dump_path}")

    puts "\n\n################ Delete old dumps ################\n\n"
    Dir.chdir(dumps_path)
    dumps_for_remove = Dir.glob("#{dump_name_template}*").reject { |file|  file == dump_name }
    FileUtils.rm_rf(dumps_for_remove)
  end
end
