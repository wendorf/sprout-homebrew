launch_agents_path = File.expand_path("~/Library/LaunchAgents")

directory launch_agents_path do
  action :create
  recursive true
  owner node['sprout']['user']
end


node["sprout"]["homebrew"]["launchctl"].each do |package, subcommand|

  plist_filename = "homebrew.mxcl.#{package}.plist"
  installation_path = File.expand_path("/usr/local/opt/#{package}")

  source_plist_filename = File.join(installation_path, plist_filename)
  launch_agent_plist_filename = File.join(launch_agents_path, plist_filename)

  case subcommand
  when "load"

    link launch_agent_plist_filename do
      to source_plist_filename
    end

    execute "start now" do
      command "launchctl load -w #{launch_agent_plist_filename}"
      user node['sprout']['user']
    end

  when "unload"

    execute "stop" do
      command "launchctl unload -w #{launch_agent_plist_filename}"
      user node['sprout']['user']
      only_if "test -L #{launch_agent_plist_filename}"
    end

    link launch_agent_plist_filename do
      action :delete
      only_if "test -L #{launch_agent_plist_filename}"
    end

  when "reload"

    execute "stop now" do
      command "launchctl unload -w #{launch_agent_plist_filename}"
      user node['sprout']['user']
    end

    execute "start now" do
      command "launchctl load -w #{launch_agent_plist_filename}"
      user node['sprout']['user']
    end

  end

end
