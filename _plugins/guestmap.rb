# coding: utf-8
module Jekyll
  class Guestmap < Generator
    safe true
    priority :high

    # Generate a transposed episode-to-guest map. This is needed to avoid a
    # quadratic scan in table generation.
    #
    # The resulting guest list for each episode is injected back into the
    # episode as a .guests array, ordered by name. Furthermore, each guest is
    # given a .hyperlink attribute to use when generating markup.
    def generate(site)
      emap = {}
      site.collections['episodes'].docs.each do |doc|
        emap[doc.data['episode']] = doc
      end

      gmap = {}
      site.data['guests'].each do |guest|
        name = guest['name'].gsub " ", " "
        if guest.key? 'twitter' then
          guest['hyperlink'] = '<a href="https://twitter.com/%s">%s</a>' %
                               [ guest['twitter'], name]
        elsif guest.key? 'url' then
          guest['hyperlink'] = '<a href="%s">%s</a>' % [guest['url'], name]
        else
          guest['hyperlink'] = name
        end

        guest['episodes'].each do |ep|
          if not gmap.key? ep then
            gmap[ep] = []
          end
          gmap[ep] << guest
        end
      end
      gmap.each do |key, val|
        emap[key].data['guests'] = val.sort_by {|x| x['name']}
      end
    end
  end
end
