module Jekyll
  class Redirects < Generator
    safe true
    priority :low

    # Only generate redirections if enabled in the main config.
    def generate(site)
      generate_redirects(site) if (site.config['stream_redirect'])
    end

    # Find all entries with a stream link and create a new page to redirect to
    # the stream URL for the corresponding episode.
    def generate_redirects(site)
      site.collections['episodes'].docs.each do |ep|
        site.config['stream_redirect'].each do |path, tkey|
          if not ep[tkey] then next end
          src = '%s/%s' % [path, ep['episode']]
          redirect = RedirectPage.new(site, site.source, src, ep[tkey])
          redirect.render(site.layouts, site.site_payload)
          redirect.write(site.dest)
          site.pages << redirect
        end
      end
    end
  end

  # A Page that injects the specified redirects.
  class RedirectPage < Page
    def initialize(site, base, path, destination)
      @site = site
      @base = base
      @dir  = path
      @name = 'index.html'
      self.process(@name)

      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'redirect.html')
      self.data['source_url'] = destination
    end
  end
end
