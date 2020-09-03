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
    #   values: [string] -- data fields to try in order (as value)
    #   template: string -- (optional) string template for value
    #
    # If the entry has fixed:true, then it generates only a single redirect to
    # a fixed target URL (target).
    def generate_redirects(site)
      first = true
      site.collections['episodes'].docs.reverse.each do |ep|
        site.config['static_redirect'].each do |path, tkey|
          if tkey['fixed'] then next end # see below

          target = find_target(ep, search_keys(tkey))
          if not target then next end

          if tkey.key? 'template' then
            target = tkey['template'] % {:value => target}
          end

          write_page(site, '%s/%s' % [path, ep['episode']], target)
          if first then
            write_page(site, '%s/latest' % path, target)
          end
        end
        first = false
        end

      site.config['static_redirect'].each do |path, tkey|
        if not tkey['fixed'] then next end # handled above
        write_page(site, path, tkey['target'])
      end
    end

    # Generate a redirect page to the given path.
    def write_page(site, src, target)
      redirect = RedirectPage.new(site, site.source, src, target)
      redirect.render(site.layouts, site.site_payload)
      redirect.write(site.dest)
      site.pages << redirect
    end

    # Return the target URL selected by the given keys, or nil.
    def find_target(ep, keys)
      keys.each do |key|
        if ep.data.key? key then return ep.data[key]
        elsif ep.respond_to? key then return ep.send(key)
        end
      end
      nil
    end

    # Return an array of keys to try, or nil if there are none.
    def search_keys(tkey)
      if tkey.key? 'value' then
        [tkey['value']]
      else
        tkey['values'] || []
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
