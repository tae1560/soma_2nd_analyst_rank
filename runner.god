God.watch do |w|
  w.name = "crawl_entry"
  w.dir = "/home/tae1560/apps/soma_2nd_analyst_rank/current/"
  w.log = "/home/tae1560/apps/soma_2nd_analyst_rank/current/log/calculate_simulation_daemon.log"
  w.start = "bundle exec rake manager:calculate_simulation_daemon RAILS_ENV=production"
  w.keepalive
end