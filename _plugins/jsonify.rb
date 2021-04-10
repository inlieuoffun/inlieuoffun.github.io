require 'fileutils'
require 'json'

module Jekyll
  class JSONify < Generator
    safe true
    priority :low

    def generate(site)
      generate_episodes(site)
      generate_guests(site)
    end

    def generate_episodes(site)
      all = {:episodes => []}
      first = true
      site.collections['episodes'].docs.reverse.each do |ep|
        latest = ep if latest == nil
        msg = {
          :episode => ep.data['episode'],
          :airDate => ep.data['date'].strftime('%Y-%m-%d'),
          :summary => ep.data['summary'],
          :topics => ep.data['topics'],
          :stream => {
            :crowdcast => ep.data['crowdcast'],
            :youTube => ep.data['youtube'],
            :acast => ep.data['acast'],
          }.compact,
          :special => ep.data['special'],
        }.compact
        msg[:guestNames] = ep.data['guests'].map {|v| v['name']} if ep.data['guests']
        msg[:links] = ep.data['links'].map do |v|
          {:title => v['title'], :url => v['url']}
        end if ep.data['links']
        cp = msg.clone

        # For detail, record a flag in the full list, put the text in the
        # single file.
        detail = ep.content.strip
        cp[:hasDetail] = detail.size > 0
        msg[:detail] = detail if detail.size > 0

        all[:episodes].push cp

        write_json(site, 'episode', '%s.json' % msg[:episode], {:episode => msg})
        if first then
          write_json(site, '', 'latest.json', {:latest => msg})
          first = false
        end
      end
      write_json(site, '', 'episodes.json', all)
    end

    def generate_guests(site)
      all = {:guests => site.data['guests'].reverse.map do |guest|
               {
                 :name => guest['name'],
                 :episodes => guest['episodes'],
                 :twitter => guest['twitter'],
                 :url => guest['url'],
                 :notes => guest['notes'],
               }.compact
             end
            }
      write_json(site, '', 'guests.json', all)
    end

    def write_json(site, dir, name, msg)
      site.static_files << JSONFile.new(site, site.dest, dir, name, msg)
    end

    # JSONFile simulates a static file but the original content is generated
    # instead of copied from the source directory.
    #
    # There might be a better way to do this, but Jekyll's plumbing for files
    # is a little tricky due to various layers of rendering. This was the
    # easiest solution I could come up with.
    class JSONFile < StaticFile
      def initialize(site, base, dir, name, msg)
        super(site, base, dir, name)
        @blob = JSON.pretty_generate(msg) # vs. msg.to_json
      end

      # Always consider this file type to require writing.
      def modified? ; true end

      # This is essentially the parent logic, but writes the generated data out
      # instead of copying an existing file.
      def write(dest)
        dest_path = destination(dest)

        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.rm(dest_path) if File.exist?(dest_path)
        File.open(dest_path, "w") do |f|
          f.write @blob
          f.close
        end
      end
    end
  end
end
