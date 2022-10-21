class DeployCommand < AppCommand

  set :user,       ENV["dev.deploy.user"]
  set :site,       ENV["dev.deploy.site"]
  set :host,       ENV["dev.deploy.host"]
  set :port,       ENV["dev.deploy.port"]

  def self.call args
    @user = get :user
    @site = get :site
    @host = get :host
    @port = get :port

    clear_cache

    if args[0] == "setup"
      deploy_nginx_site
      install_nginx_site
      call []
    else
      cache_request RootRequest
      deploy_cached_requests
    end
  end

  #

  def self.clear_cache
    log "Clearing cache"
    FileUtils.rm_rf tmp_folder, verbose: true
    FileUtils.mkdir_p tmp_folder, verbose: true
  end

  #

  def self.deploy_nginx_site
    path_nginx_site = "#{tmp_folder}/#{@site}.nginx"
    erb_template = File.read "#{App.fname_for self}/site.nginx.erb"
    content_nginx_site = ERB.new(erb_template).result(binding)
    File.write path_nginx_site, content_nginx_site

    puts "\n\n#{content_nginx_site}".black.on_light_green

    log "deploying nginx site"
    Kernel.system %|scp #{path_nginx_site} #{@user}@#{@host}:.|
  end

  def self.install_nginx_site
    path_setup_sh = "#{tmp_folder}/#{@site}.setup.sh"
    erb_template = File.read "#{App.fname_for self}/setup.sh.erb"
    content_nginx_site = ERB.new(erb_template).result(binding)
    File.write path_setup_sh, content_nginx_site

    puts "\n\n#{content_nginx_site}".black.on_light_green

    log "installing nginx site"
    Kernel.system "cat #{path_setup_sh} | ssh #{@user}@#{@host}"
  end

  #

  def self.cache_request request_klass
    request_klass::ACTIONS.keys.each do |action|
      log "Writing cache for #{request_klass} action: #{action}"

      env = {}
      # env["LIZA_PATH"] = path
      # env["LIZA_REQUEST"] = request
      env["LIZA_ACTION"] = action
      # env["LIZA_FORMAT"] = format

      _, _, body = request_klass.call env
      body = body[0]

      fname = "#{tmp_folder}/#{action}.html"

      File.write fname, body, verbose: true

      log "--- #{fname} #{body.size} bytes"
    end
  end

  def self.deploy_cached_requests
    log "deploying cached requests"
    Kernel.system %|scp #{tmp_folder}/* #{@user}@#{@host}:#{@site}/.|

    log "deploying web_files"
    Kernel.system %|scp web_files/* #{@user}@#{@host}:#{@site}/.|

    log "done"
  end

  #

  def self.tmp_folder
    "tmp/deploy_files"
  end

end
