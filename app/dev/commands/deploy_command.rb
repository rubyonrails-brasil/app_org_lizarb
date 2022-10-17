class DeployCommand < AppCommand

  set :user,       ENV["dev.deploy.user"]
  set :host,       ENV["dev.deploy.host"]
  set :path,       ENV["dev.deploy.path"]

  def self.call args
    clear_cache
    cache RootRequest
    deploy
  end

  def self.clear_cache
    log "Clearing cache"
    FileUtils.rm_rf tmp_folder, verbose: true
    FileUtils.mkdir_p tmp_folder, verbose: true
  end

  def self.cache request_klass
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

  def self.deploy
    user = get :user
    host = get :host
    path = get :path

    log "deploying cached requests"
    Kernel.system %|scp #{tmp_folder}/* #{user}@#{host}:#{path}.|

    log "deploying web_files"
    Kernel.system %|scp web_files/* #{user}@#{host}:#{path}.|

    log "done"
  end

  def self.tmp_folder
    ENV["dev.deploy.tmp_folder"]
  end

end
