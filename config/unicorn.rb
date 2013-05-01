root = "/home/tae1560/apps/soma_2nd_analyst_rank/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.soma_2nd_analyst_rank.sock"
worker_processes 2
timeout 30