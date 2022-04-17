# coding: utf-8
require 'porter2stemmer'

module Jekyll
  class Indexer < Generator
    safe true
    priority :low

    # Generate an inverted index of terms mentioned in episode descriptions.
    def generate(site)
      index = {} # :: episode → term → count
      etags = {} # :: tag → doc
      terms = {} # :: word → ndocs (for stopwording)
      site.collections['episodes'].docs.each do |doc|
        di = index_doc(doc)
        index[doc.data['episode']] = di
        di.each do |word, count|
          terms[word] = (terms[word] || 0) + 1
        end

        # Add tags for the explicitly-defined tags.
        (doc.data['tags'] || []).each do |tag|
          add_tag(etags, tag, doc.data['episode'])
        end

        # Add implicit tags for other interesting properties.
        if (doc.data['links'] || []).length > 0 then
          add_tag(etags, 'has:links', doc.data['episode'])
        end
        if doc.data['acast'] then
          add_tag(etags, 'has:audio', doc.data['episode'])
        end
        if doc.content.strip.size > 0 then
          add_tag(etags, 'has:detail', doc.data['episode'])
        end
        if doc.data['special'] then
          add_tag(etags, 'is:special', doc.data['episode'])
        end
      end

      # Compute stopwords based on prevalence and length.
      ndocs = index.length.to_f
      stops = {'' => true}
      terms.each do |word, count|
        if word.include? '_' or word.length > 25 or (count/ndocs) > 0.11 then
          stops[word] = true
        elsif word.length > 4 and word.match? /^\d+$/ then
          stops[word] = true  # probably crap from URLs.
        end
      end

      # Compute the inverted index, terms to array of document, count.
      invert = {}
      index.each do |doc, docindex|
        docindex.each do |word, count|
          next if stops[word]
          if not invert.has_key? word then
            invert[word] = {}
          end
          invert[word][doc] = count
        end
      end

      msg = {
        :terms => invert.sort_by {|word, v| word}.to_h,
        :tags => etags.sort_by {|tag, v| tag}.to_h,
      }
      write_json(site, '', 'index.json', {:index => msg})
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
        @blob = msg.to_json
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

    def add_tag(map, tag, elt)
      if not map.has_key? tag then
        map[tag] = []
      end
      map[tag].append elt
    end

    def index_doc(doc)
      index = {}
      index_string(doc.data['summary'] || '').each do |word, count|
        index[word] = (index[word] || 0) + count
      end
      index_string(doc.content).each do |word, count|
        index[word] = (index[word] || 0) + count
      end
      return index
    end

    def index_string(s)
      index = {}
      parse_string(s).each do |word|
        index[word] = (index[word] || 0) + 1
      end
      return index
    end

    def parse_string(s)
      s.strip.downcase.split(/\W+/).map {|w| w.stem(true) }
    end
  end
end
