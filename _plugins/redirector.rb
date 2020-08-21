module Jekyll
  class Redirector < Generator
    safe true
    priority :low

    # Only generate redirections if enabled in the main config.
    def generate(site)
      generate_redirects(site) if (site.config['static_redirect'])
    end

    # Find all entries with a matching link value and create a new page to
    # redirect to the specified URL for the corresponding episode.
    #
    # Each redirect entry names a path fragment with keys:
    #
    #   value: string    -- data field or method providing target URL
    #   template: string -- (optional) string template for value
    #
    def generate_redirects(site)
      site.collections['episodes'].docs.each do |ep|
        site.config['static_redirect'].each do |path, tkey|
          value = tkey['value']
          if not value then next end

          if ep.data.key? value then target = ep.data[value]
          elsif ep.respond_to? value then target = ep.send(value)
          else next end

          if tkey.key? 'template' then
            target = tkey['template'] % {:value => target}
          end

          src = '%s/%s' % [path, ep['episode']]
          redirect = RedirectPage.new(site, site.source, src, target)
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
