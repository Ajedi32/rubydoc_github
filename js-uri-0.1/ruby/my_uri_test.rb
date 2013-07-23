require "test/unit"

require "my_uri"

class TestMyUri < Test::Unit::TestCase
  def test_parse
    assert_uri("http://www.example.com/foo/bar?page=1\#baz",
               "http", "www.example.com", "/foo/bar", "page=1", "baz")
  end

  def test_parse_query_string_only
    assert_uri("?page=1", nil, nil, nil, "page=1")
  end

  def test_parse_fragment_only
    assert_uri("\#foo", nil, nil, nil, nil, "foo")
  end

  def test_parse_path_and_query
    assert_uri("/foo/bar?baz=quux", nil, nil, "/foo/bar", "baz=quux")
  end

  def test_authority_and_path
    assert_uri("//example.com/foo/bar", nil, "example.com", "/foo/bar")
  end

  def test_parse_scheme_only
    assert_uri("http:", "http")
  end

  # This is actually valid, and represents the current URI.
  def test_parse_empty
    assert_uri("")
  end

  # A little helper.
  def assert_uri(str, scheme=nil, authority=nil, path=nil, query=nil, fragment=nil)
    uri = MyURI.parse(str)
    assert_not_nil(uri, "parse() return value")
    assert_equal(scheme, uri.scheme, "Scheme component of “#{str}”")
    assert_equal(authority, uri.authority, "Authority component of “#{str}”")
    assert_equal(path, uri.path, "Path component of “#{str}”")
    assert_equal(query, uri.query, "Query component of “#{str}”")
    assert_equal(fragment, uri.fragment, "Fragment component of “#{str}”")
    assert_equal(str, uri.to_s, "Reconstruction of original URI")
  end

  # Example from RFC3986 §5.4.1 (Normal Examples).
  BASE_URI = "http://a/b/c/d;p?q"
  [
    # Normal examples.
    ["g:h",     "g:h"],
    ["g",       "http://a/b/c/g"],
    ["./g",     "http://a/b/c/g"],
    ["g/",      "http://a/b/c/g/"],
    ["/g",      "http://a/g"],
    ["//g",     "http://g"],
    ["?y",      "http://a/b/c/d;p?y"],
    ["g?y",     "http://a/b/c/g?y"],
    ["#s",      "http://a/b/c/d;p?q#s"],
    ["g#s",     "http://a/b/c/g#s"],
    ["g?y#s",   "http://a/b/c/g?y#s"],
    [";x",      "http://a/b/c/;x"],
    ["g;x",     "http://a/b/c/g;x"],
    ["g;x?y#s", "http://a/b/c/g;x?y#s"],
    ["",        "http://a/b/c/d;p?q"],
    [".",       "http://a/b/c/"],
    ["./",      "http://a/b/c/"],
    ["..",      "http://a/b/"],
    ["../",     "http://a/b/"],
    ["../g",    "http://a/b/g"],
    ["../..",   "http://a/"],
    ["../../",  "http://a/"],
    ["../../g", "http://a/g"],

    # Abnormal examples.
    # 1. Going up further than is possible.
    ["../../../g",    "http://a/g"],
    ["../../../../g", "http://a/g"],
    
    # 2. Not matching dot boundaries correctly.
    ["/./g",  "http://a/g"],
    ["/../g", "http://a/g"],
    ["g.",    "http://a/b/c/g."],
    [".g",    "http://a/b/c/.g"],
    ["g..",   "http://a/b/c/g.."],
    ["..g",   "http://a/b/c/..g"],
    
    # 3. Nonsensical path segments.
    ["./../g",     "http://a/b/g"],
    ["./g/.",      "http://a/b/c/g/"],
    ["g/./h",      "http://a/b/c/g/h"],
    ["g/../h",     "http://a/b/c/h"],
    ["g;x=1/./y",  "http://a/b/c/g;x=1/y"],
    ["g;x=1/../y", "http://a/b/c/y"],
    
    # 4. Paths in the query string should be ignored.
    ["g?y/./x",  "http://a/b/c/g?y/./x"],
    ["g?y/../x", "http://a/b/c/g?y/../x"],
    ["g#s/./x",  "http://a/b/c/g#s/./x"],
    ["g#s/../x", "http://a/b/c/g#s/../x"],
    
    # 5. Backwards compatibility
    ["http:g", "http:g"],
    
  ].each_with_index do |t, i|
    base = MyURI.parse(BASE_URI)
    # Dynamically create a test for each example.
    define_method "test_resolution_#{i}".to_sym do
      rel  = MyURI.parse(t[0])
      assert_equal(t[1], rel.resolve(base).to_s,
                   "Resolve '#{rel}' against '#{base}'")
    end
  end

end