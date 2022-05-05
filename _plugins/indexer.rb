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

    @stemcache

    # Generate an inverted index of terms mentioned in episode descriptions.
    def generate(site)
      # The stemmer turns out to be incredibly slow, so keep a cache of words
      # to their stems. Otherwise generating the inverted index takes minutes.
      @stemcache = {}

      index = {} # :: episode → term → count
      etags = {} # :: tag → doc
      terms = {} # :: word → ndocs (for stopwording)

      Jekyll.logger.info "Indexing episode details and summaries..."
      site.collections['episodes'].docs.each do |doc|
        ep = doc.data['episode']
        di = index_doc(doc)
        index[ep] = di
        di.each do |word, count|
          terms[word] = (terms[word] || 0) + 1
        end

        # Add tags for the explicitly-defined tags.
        (doc.data['tags'] || []).each do |tag|
          add_tag(etags, 'tag:'+tag, ep)
        end

        # Add tags for the names of guests.
        guests = doc.data['guests'] || []
        if guests.length != 0 then
          add_tag(etags, 'has:guests', ep)
          guests.each do |guest|
            parse_string(guest['name']).each do |part|
              add_tag(etags, 'guest:'+part, ep) if part.length > 1
            end
            if guest['twitter'] then
              add_tag(etags, '@'+guest['twitter'].downcase, ep)
            end
          end
        end

        # Add implicit tags for other interesting properties.
        if (doc.data['links'] || []).length > 0 then
          add_tag(etags, 'has:links', ep)
        end
        if doc.data['acast'] then
          add_tag(etags, 'has:audio', ep)
        end
        if doc.content.strip.size > 0 then
          add_tag(etags, 'has:detail', ep)
        end
      end

      # If we're indexing transcripts, include those now.
      if site.config['indexer']['index_transcripts'] then
        index_transcripts(site.collections['episodes'].docs, index)
      end

      # Compute stopwords based on prevalence and length.
      Jekyll.logger.info "Constructing stopword index..."
      ndocs = index.length.to_f
      stops = $english_stopwords.clone
      terms.each do |word, count|
        if word.length < 2 or word.include? '_' or word.length > 25 then
          stops.add word
        elsif word.length != 4 and word.match? /^\d+$/ then
          stops.add word
        end
      end
      Jekyll.logger.info format("Stopword list is %d elements (%d base)",
                                stops.size, $english_stopwords.size)

      # Compute the inverted index, mapping each stem to a map of document to
      # an array of specific (non-stemmed) terms.
      Jekyll.logger.info "Constructing inverted index..."
      invert = {}
      last, ndocs = 0, 0
      index.each do |doc, docindex|
        docindex.each do |word, count|
          next if stops.include? word
          stem = word_stem(word)
          if not invert.has_key? stem then
            invert[stem] = {}
          end
          if not invert[stem].has_key? word then
            invert[stem][word] = []
          end
          invert[stem][word].append doc
        end
        last += 1
        ndocs += 1
        if last == 25 then
          Jekyll.logger.info format("Processed %d documents (%d terms so far)", ndocs, invert.length)
          last = 0
        end
      end
      Jekyll.logger.info "Adding episode tags..."
      etags.each do |tag, eps|
        invert[tag] = {tag => eps}
      end

      Jekyll.logger.info "Writing index data to output..."
      msg = {
        :terms => invert.sort_by {|stem, _| stem}.to_h,
        :stops => stops.to_a.sort,
        :tags  => etags.keys.
                    filter {|x| x.start_with? 'tag:'}.
                    map {|x| x.delete_prefix('tag:')}.
                    sort
      }
      write_json(site, '', 'textindex.json', {:index => msg})
      Jekyll.logger.info "Indexing complete"
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
      index_string(doc.data['summary'] || '', index)
      index_string(doc.content, index)
      return index
    end

    def index_transcripts(docs, combined)
      Jekyll.logger.info "Indexing episode transcripts..."
      indices = []
      threads = []
      total = 0
      docs.each do |doc|
        next unless doc.data['transcript']
        if threads.length > 64 then
          threads.each(&:join)
          threads = []
          Jekyll.logger.info format("Finished indexing transcript %d of %d", total, docs.length)
        end
        index = {}
        indices << {'doc' => doc.data['episode'], 'idx' => index}
        threads << Thread.new { index_transcript(doc.data['transcript'], index) }
        total += 1
      end
      threads.each(&:join)
      Jekyll.logger.info format("Finished indexing transcript %d of %d", total, docs.length)
      Jekyll.logger.info "Combining index results..."
      indices.each do |elt|
        target = combined[elt['doc']]
        elt['idx'].each do |word, count|
          target[word] = (target[word] || 0) + count
        end
      end
      Jekyll.logger.info "Transcript indexing complete"
    end

    def index_string(s, index)
      parse_string(s).each do |word|
        index[word] = (index[word] || 0) + 1
      end
    end

    def index_transcript(ts, index)
      bits = File.read(ts.path)
      JSON.load(bits)['transcript']['captions'].each do |c|
        index_string(c['text'], index)
      end
    end

    def parse_string(s)
      s.strip.
        gsub(/\[([^\]]+)\]\([^\)]+\)/, '\1').
        gsub(/\bhttps?:\/\/\S+/, '').
        gsub(/([a-z]+)\d+/i, '\1').
        downcase.split(/\W+/).
        map {|x| x.gsub /(^_+|_+$)/, ''}
    end

    def word_stem(word)
      @stemcache[word] ||= word.stem(true)
      @stemcache[word]
    end
  end
end
