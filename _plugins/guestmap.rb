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
      # Check for episode transcripts.
      tmap = {}
      site.collections['transcripts'].files.each do |file|
        m = file.path.match /-([\w.]+)\.json$/
        next unless m
        next unless File.size(file.path) > 0
        ep = m.captures[0].to_s.sub( /^0+/, '') || "0"
        tmap[ep] = file
      end

      emap = {}
      site.collections['episodes'].docs.each do |doc|
        ep = doc.data['episode']
        emap[ep] = doc
        doc.data['transcript'] = tmap[ep.to_s]
        doc.data['special'] = (doc.data['tags'] || []).include? 'special'
      end

      gmap = {}
      site.data['guests'].each do |guest|
        if not guest['episodes'] then next end
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
        # Produce a usable diagnostic in cases where a guest is attributed to
        # an episode with no corresponding file.
        if not emap.key? key then
          raise Exception.new "Guest '#{val[0]['name']}' refers to unknown episode number '#{key}'"
        end
        emap[key].data['guests'] = val.sort_by {|x| x['name']}
      end

      # Produce a "leaderboard" of frequent guests.
      # Frequent is defined as having at least 4 visits, and results are ordered
      # by number of visits with ties broken in favour of earliest episode.
      freq = site.data['guests'].select do |g| g['episodes'].size >= 4 end.sort_by {|g|
        [-g['episodes'].size, g['episodes'][0]]
      }
      site.data['leaderboard'] = freq
    end
  end
end
