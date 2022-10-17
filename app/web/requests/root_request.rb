class RootRequest < AppRequest

  ACTIONS = {
    "index" => "Getting Started",
    "primeira" => "Sua Primeira Aplicacao",
  }

  # NOTE: There's a bug in this file. Can you find it?
  def self.call env
    action = env["LIZA_ACTION"]

    # default

    status = 200

    headers = {
      "Framework" => "Liza #{Lizarb::VERSION}"
    }

    body = ""

    # action

    case action
    when *ACTIONS.keys
      body = render_action action
    else
      status = 404
      body = render_action_not_found
    end

    # result

    log status
    [status, headers, [body]]
  rescue => e
    status = 500
    body = "#{e.class} - #{e.message}"

    log status
    [status, headers, [body]]
  end

  def self.render_action action
    title = ACTIONS[action]

    header = render_header

    content_md = File.read "#{App.fname_for self}/action.#{action}.md"
    content = md_to_html content_md

    layout_html = File.read "#{App.fname_for self}/layout.html"
    layout_html.gsub! "%TITLE%", title
    layout_html.gsub! "%HEADER%", header
    layout_html.gsub! "%BODY%", content
    layout_html
  end

  def self.render_action_not_found
    "Ruby couldn't find your page!"
  end

  def self.render_header
    links = []

    ACTIONS.each do |action, title|
      links << %|<a href="/#{action}.html">#{title}</a>|
    end

    links.join " | "
  end

  # https://github.com/gjtorikian/commonmarker#usage
  def self.md_to_html text
    CommonMarker.render_html text, [:HARDBREAKS, :SOURCEPOS, :UNSAFE]
  end

end
