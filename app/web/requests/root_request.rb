class RootRequest < AppRequest

  # NOTE: There's a bug in this file. Can you find it?
  def self.call env
    action = env["LIZA_ACTION"]

    #

    status = 200

    headers = {
      "Framework" => "Liza #{Lizarb::VERSION}"
    }

    body = ""

    if action == "root"
      body = render_action action
    else
      status = 404
      body = render_action_not_found
    end

    log status
    [status, headers, [body]]
  rescue => e
    status = 500
    body = "#{e.class} - #{e.message}"

    log status
    [status, headers, [body]]
  end

  def self.render_action action
    "Ruby Works! (#{action})"
  end

  def self.render_action_not_found
    "Ruby couldn't find your page!"
  end

end
