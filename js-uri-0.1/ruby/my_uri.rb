# @(#) $Id: my_uri.rb 7 2007-04-26 18:59:47Z happygiraffe.net $

class MyURI
  attr_accessor :scheme, :authority, :path, :query, :fragment

  # Based on the regex in RFC2396 Appendix B.
  PARSE_RE = /^
              (?:
                ([^:\/?\#]+)        # Scheme
                :
              )?
              (?:
                \/\/
                ([^\/?\#]*)         # Authority
              )?
              (
                [^?\#]*             # Path
              )
              (?:
                \?
                ([^\#]*)            # Query String
              )?
              (?:
                \#
                (.*)                # Fragment
              )?
              /x

  # Parse a string into a MyURI object.
  def self.parse(str)
    md = str.match(PARSE_RE)
    # Turn empty strings into nil.
    # XXX Decode %-escapes.
    components = md[1..5].map { |str| str == "" ? nil : str }
    self.new(*components)
  end

  def initialize(scheme, authority, path, query, fragment)
    @scheme    = scheme
    @authority = authority
    @path      = path
    @query     = query
    @fragment  = fragment
  end
  
  # Should only create new objects through parse.
  protected :initialize
  
  def to_s
    str = ""
    str << "#{scheme}:"     if scheme
    str << "//#{authority}" if authority
    str << path             if path
    str << "?#{query}"      if query
    str << "\##{fragment}"  if fragment
    str
  end
  
  # RFC3986 §5.2.2. Transform References
  def resolve(base)
    target_scheme    = nil
    target_authority = nil
    target_path      = nil
    target_query     = nil

    if self.scheme then
      target_scheme    = self.scheme
      target_authority = self.authority
      target_path      = remove_dot_segments(self.path)
      target_query     = self.query
    else
      if self.authority then
        target_authority = self.authority
        target_path      = remove_dot_segments(self.path)
        target_query     = self.query
      else
        # XXX Original spec says "if defined and empty"…
        if !self.path then
          target_path = base.path
          if self.query then
            target_query = self.query
          else
            target_query = base.query
          end
        else
          if self.path[0] == ?/ then
            target_path = remove_dot_segments(self.path)
          else
            target_path = merge(base, self.path)
            target_path = remove_dot_segments(target_path)
          end
          target_query = self.query
        end
        target_authority = base.authority
      end
      target_scheme = base.scheme
    end

    MyURI.new(target_scheme, target_authority, target_path, target_query,
              self.fragment)
  end
  
  # A regex to match a parent directory as part of a path.
  DOUBLEDOT = /
    \/              # Slash
    (
      (?!\.\.\/)    # The parent directory cannot be ".."
      [^\/]*        # Everything up to the next slash.
    )
    \/              # Slash
    \.\.            # ".."
    \/              # Slash
  /x

  # This is my own attempt at writing everything with regexes rather than
  # follow the somewhat convoluted RFC spec.
  def remove_dot_segments(path)
    return unless path
    newpath = path.dup
    # Remove any single dots
    newpath.gsub!(/\/\.\//, '/')
    # Remove any trailing single dots.
    newpath.sub!(/\/\.$/, '/')
    # Remove any double dots and the path previous.  NB: We can't use gsub()
    # because we are changing the string that we're matching over.
    newpath.sub!(DOUBLEDOT, '/') while newpath =~ DOUBLEDOT
    # Remove any trailing double dots.
    newpath.sub!(/\/([^\/]*)\/\.\.$/, '/')
    # If there are any remaining double dot bits, then they're wrong and must 
    # be nuked.  Again, we can't use gsub.
    newpath.sub!(/\/\.\.\//, '/') while newpath =~ /\/\.\.\//
    newpath
  end
  
  def merge(base, rel_path)
    if base.authority && !base.path
      "/#{rel_path}"
    else
      /^(.*)\//.match(base.path)[0] + rel_path
    end
  end
end