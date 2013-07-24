God.watch do |w|
  w.name = "calculate_simulation_daemon"
  w.dir = "/Users/tae1560/RubymineProjects/composer_test/analyst_rank/"
  w.log = "/Users/tae1560/RubymineProjects/composer_test/analyst_rank/log/calculate_simulation_daemon.log"
  w.start = "bundle exec rake manager:calculate_simulation_daemon RAILS_ENV=development"
  w.keepalive
end