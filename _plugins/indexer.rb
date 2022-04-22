# coding: utf-8
require 'porter2stemmer'

$english_stopwords = ["i", "me", "my", "myself", "we", "our", "ours",
"ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him",
"his", "himself", "she", "her", "hers", "herself", "it", "its", "itself",
"they", "them", "their", "theirs", "themselves", "what", "which", "who",
"whom", "this", "that", "these", "those", "am", "is", "are", "was", "were",
"be", "been", "being", "have", "has", "had", "having", "do", "does", "did",
"doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until",
"while", "of", "at", "by", "for", "with", "about", "against", "between",
"into", "through", "during", "before", "after", "above", "below", "to", "from",
"up", "down", "in", "out", "on", "off", "over", "under", "again", "further",
"then", "once", "here", "there", "when", "where", "why", "how", "all", "any",
"both", "each", "few", "more", "most", "other", "some", "such", "no", "nor",
"not", "only", "own", "same", "so", "than", "too", "very", "s", "t", "can",
"will", "just", "don", "should", "now"].to_set

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
        if $english_stopwords.include? word then
          stops[word] = true
        elsif word.length < 2 or word.include? '_' or word.length > 25 or (count/ndocs) > 0.12 then
          stops[word] = true
        elsif word.length != 4 and word.match? /^\d+$/ then
          stops[word] = true  # probably crap from URLs.
        end
      end

      # Compute the inverted index, mapping each stem to a map of document to
      # an array of specific (non-stemmed) terms.
      invert = {}
      index.each do |doc, docindex|
        docindex.each do |word, count|
          next if stops[word]
          stem = word.stem(true)
          if not invert.has_key? stem then
            invert[stem] = {}
          end
          if not invert[stem].has_key? word then
            invert[stem][word] = []
          end
          invert[stem][word].append doc
        end
      end

      # For rendering, map to array of objects.
      site.data['textindex'] = invert.sort_by {|stem, _| stem}.to_h.flat_map do |_, item|
        item.map {|word, ep| {'word' => word, 'episodes' => ep }}
      end

      msg = {
        :terms => invert.sort_by {|stem, _| stem}.to_h,
        :tags => etags.sort_by {|tag, v| tag}.to_h,
      }
      write_json(site, '', 'textindex.json', {:index => msg})
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
      s.strip.
        gsub(/\[([^\]]+)\]\([^\)]+\)/, '\1').
        gsub(/\bhttps?:\/\/\S+/, '').
        gsub(/([a-z]+)\d+/i, '\1').
        downcase.split(/\W+/)
    end
  end
end
