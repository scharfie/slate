require 'test/unit'
require File.dirname(__FILE__) + '/../lib/css_dryer'

class TestCssDryer < Test::Unit::TestCase
  include CssDryer

  def test_should_build_structure_without_nesting
    css = <<END
/* comment 0 */
s0 {
  k00: v00;
  k01: v01;
}
/* comment 1 */
s1 { k10: v10; }
s2 {
  k20: v20;
  /* comment 2 */
  k21: v21;
}
END
    output = nested_css_to_structure(css)
    assert_equal 5, output.length

    assert_equal '/* comment 0 */', output.shift

    hsh = output.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's0', hsh.keys.first
    ary = hsh.values.first
    assert_equal 2, ary.length
    assert_equal '  k00: v00;', ary.first
    assert_equal '  k01: v01;', ary.last

    assert_equal '/* comment 1 */', output.shift

    hsh = output.shift
    assert_equal 1, hsh.length
    assert ! hsh.multiline
    assert_equal 's1', hsh.keys.first
    ary = hsh.values.first
    assert_equal 1, ary.length
    assert_equal ' k10: v10; ', ary.first

    hsh = output.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's2', hsh.keys.first
    ary = hsh.values.first
    assert_equal 3, ary.length
    assert_equal '  k20: v20;', ary.shift
    assert_equal '  /* comment 2 */', ary.shift
    assert_equal '  k21: v21;', ary.shift
  end

  def test_should_build_structure_with_nesting
    css = <<END
/* comment 0 */
s0 {
  k00: v00;
  k01: v01;
}
s1 {
  k10: v10;
  /* comment 1 */
  s2 {
    k20: v20;
    k21: v21;
  }
  k11: v11;
  s3 { k30: v30; }
}
END

# [
#   '/* comment 0 */',
#   { 's0' => [ '  k00: v00;', '  k01: v01;' ] },
#   { 's1' => [ '  k10: v10;',
#               '  /* comment 1 */',
#               { 's2' => [ 'k20: v20;', 'k21: v21;'] },
#               '  k11: v11;',
#               { 's3' => [ ' k30: v30; ' ] } } ]
# ]
    output = nested_css_to_structure(css)
    assert_equal 3, output.length

    assert_equal '/* comment 0 */', output.shift

    hsh = output.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's0', hsh.keys.first
    ary = hsh.values.first
    assert_equal 2, ary.length
    assert_equal '  k00: v00;', ary.shift
    assert_equal '  k01: v01;', ary.shift

    hsh = output.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's1', hsh.keys.first
    ary = hsh.values.first
    assert_equal 5, ary.length

    assert_equal '  k10: v10;', ary.shift
    assert_equal '  /* comment 1 */', ary.shift
    s2_hsh = ary.shift
    assert_equal 1, s2_hsh.length
    assert s2_hsh.multiline
    assert_equal 's2', s2_hsh.keys.first
    s2_ary = s2_hsh.values.first
    assert_equal 2, s2_ary.length
    assert_equal 'k20: v20;', s2_ary.shift
    assert_equal 'k21: v21;', s2_ary.shift
    assert_equal '  k11: v11;', ary.shift
    s3_hsh = ary.shift
    assert_equal 1, s3_hsh.length
    assert ! s3_hsh.multiline
    assert_equal 's3', s3_hsh.keys.first
    s3_ary = s3_hsh.values.first
    assert_equal 1, s3_ary.length
    assert_equal ' k30: v30; ', s3_ary.shift
  end

  def test_should_build_structure_with_triple_nesting
    css = <<END
/* comment 0 */
s0 {
  k00: v00;
  k01: v01;
}
s1 {
  k10: v10;
  /* comment 1 */
  s2 {
    k20: v20;
    k21: v21;
    s3 {k30: v30;}
  }
  k11: v11;
}
END

# [
#   '/* comment 0 */',
#   { 's0' => [ '  k00: v00;', '  k01: v01;' ] },
#   { 's1' => [ '  k10: v10;',
#               '  /* comment 1 */',
#               { 's2' => [ 'k20: v20;',
#                           'k21: v21;',
#                           { 's3' => [ 'k30: v30;' ] } ] },
#               '  k11: v11;' ]
# ]
    output = nested_css_to_structure(css)
    assert_equal 3, output.length

    assert_equal '/* comment 0 */', output.shift

    hsh = output.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's0', hsh.keys.first
    ary = hsh.values.first
    assert_equal 2, ary.length
    assert_equal '  k00: v00;', ary.shift
    assert_equal '  k01: v01;', ary.shift

    hsh = output.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's1', hsh.keys.first
    ary = hsh.values.first
    assert_equal 4, ary.length
    assert_equal '  k10: v10;', ary.shift
    assert_equal '  /* comment 1 */', ary.shift
    hsh = ary.shift
    assert_equal 1, hsh.length
    assert hsh.multiline
    assert_equal 's2', hsh.keys.first
    ary_prime = hsh.values.first
    assert_equal 3, ary_prime.length
    assert_equal 'k20: v20;', ary_prime.shift
    assert_equal 'k21: v21;', ary_prime.shift
    hsh = ary_prime.shift
    assert_equal 1, hsh.length
    assert ! hsh.multiline
    assert_equal 's3', hsh.keys.first
    assert_equal 'k30: v30;', hsh.values.first.shift
    assert_equal '  k11: v11;', ary.shift
  end

  def test_should_convert_type_selectors_aka_no_nesting_structure_to_css
    structure = []
    structure << '/* comment 0 */'
    hsh = StyleHash['s0' => [ '  k00: v00;', '  k01: v01;' ] ]
    hsh.multiline = true
    structure << hsh
    structure << '/* comment 1 */'
    structure << StyleHash['s1' => [ ' k10: v10; ' ] ]
    hsh = StyleHash['s2' => [ '  k20: v20;', '  /* comment 2 */', '  k21: v21;' ] ]
    hsh.multiline = true
    structure << hsh

    assert_equal <<END, structure_to_css(structure)
/* comment 0 */
s0 {
  k00: v00;
  k01: v01;
}
/* comment 1 */
s1 { k10: v10; }
s2 {
  k20: v20;
  /* comment 2 */
  k21: v21;
}
END
  end

  def test_should_convert_descendant_selectors_structure_to_css
    structure = []
    structure << '/* comment 0 */'

    hsh_s0 = StyleHash['s0' => [ '  k00: v00;', '  k01: v01;' ] ]
    hsh_s0.multiline = true
    structure << hsh_s0

    hsh_s3 = StyleHash['s3' => [ ' k30: v30; ' ] ]
    hsh_s2 = StyleHash['s2' => [ 'k20: v20;', 'k21: v21;', hsh_s3 ] ]
    hsh_s2.multiline = true

    hsh_s1 = StyleHash['s1' => [ '  k10: v10;', '  /* comment 1 */', hsh_s2, '  k11: v11;' ] ]
    hsh_s1.multiline = true
    structure << hsh_s1

    assert_equal <<END, structure_to_css(structure)
/* comment 0 */
s0 {
  k00: v00;
  k01: v01;
}
s1 {
  k10: v10;
  /* comment 1 */
  k11: v11;
}
s1 s2 {
  k20: v20;
  k21: v21;
}
s1 s2 s3 { k30: v30; }
END
  end

  def test_should_handle_rails_tip_example_of_descendant_selectors
    input = <<END
div#content {
  /* some styles which apply only to div#content ... */
  h2 { /* some styles which apply only to div#content h2 ... */ }
  a {
    /* some styles which apply only to div#content a ... */
  }
}
END
    
    output = <<END
div#content {
  /* some styles which apply only to div#content ... */
}
div#content h2 { /* some styles which apply only to div#content h2 ... */ }
div#content a {
  /* some styles which apply only to div#content a ... */
}
END

    assert_equal output, process(input)
  end

  def test_should_handle_one_descendant_selector
    input = <<END
div p {
  color: blue;
}
END
    assert_equal input, process(input)
  end

  def test_should_handle_media_block
    input = <<END
@media screen, projection {
  div {font-size:100%;}
}
END

    output = <<END
@media screen, projection {
  div {font-size:100%;}
}
END

    assert_equal output, process(input)
  end

  def test_should_handle_inline_media_block
    input = <<END
@media screen, projection { div {font-size:100%;} }
END

    output = <<END
@media screen, projection { div {font-size:100%;} }
END

    assert_equal output, process(input)
  end

  def test_should_not_output_empty_selectors
    input = <<END
div#content {
  h2 { /* some styles which apply only to div#content h2 ... */ }
  a {
    /* some styles which apply only to div#content a ... */
  }
}
END
    
    output = <<END
div#content h2 { /* some styles which apply only to div#content h2 ... */ }
div#content a {
  /* some styles which apply only to div#content a ... */
}
END

    assert_equal output, process(input)
  end

  def test_should_not_output_blank_lines
    input = <<END
div {
  color: red;

  span { color: blue; }

  a {
    .hover { text-decoration: none; }
    .visited { text-decoration: none; }
  }

}
END
    assert_equal <<END, process(input)
div {
  color: red;
}
div span { color: blue; }
div a.hover { text-decoration: none; }
div a.visited { text-decoration: none; }
END
  end

  def test_style_hash_has_non_hash_children
    hsh = StyleHash[ 'key' => %w( foo ) ]
    assert hsh.has_non_style_hash_children
    hsh.value.pop
    hsh.value << StyleHash.new
    assert ! hsh.has_non_style_hash_children
  end

  def test_should_handle_class_selectors
    input = <<END
td {
  font-family: verdana;
  .even { background: blue;  }
  .odd {
    background: green;
    .odder-still { background: infra-red; }
  }
}
END
    
    output = <<END
td {
  font-family: verdana;
}
td.even { background: blue;  }
td.odd {
  background: green;
}
td.odd.odder-still { background: infra-red; }
END

    assert_equal output, process(input)
  end

  def test_should_handle_pseudo_class_selectors
    input = <<END
a {
  text-decoration: underline; padding: 1px;
  :link { color: #03c; }
  :visited { color: #03c; }
  :hover { color: #fff; background-color: #30c; text-decoration: none; }
  .image:link {
    background: none;
    padding: 0;
  }
}
END
    
    output = <<END
a {
  text-decoration: underline; padding: 1px;
}
a:link { color: #03c; }
a:visited { color: #03c; }
a:hover { color: #fff; background-color: #30c; text-decoration: none; }
a.image:link {
  background: none;
  padding: 0;
}
END

    assert_equal output, process(input)
  end

  def test_should_handle_id_selectors
    input = <<END
div {
  color: blue;
  border: 1px solid green;
  #flash {
    background: yellow;
    font-size: x-large;
  }
}
END
    
    output = <<END
div {
  color: blue;
  border: 1px solid green;
}
div#flash {
  background: yellow;
  font-size: x-large;
}
END

    assert_equal output, process(input)
  end

  def test_should_handle_child_selectors
    input = <<END
div {
  color: blue;
  border: 1px solid green;
  > p {
    color: yellow;
    > b { font-variant: small-caps; }
  }
}
END
    
    output = <<END
div {
  color: blue;
  border: 1px solid green;
}
div > p {
  color: yellow;
}
div > p > b { font-variant: small-caps; }
END

    assert_equal output, process(input)
  end

  def test_should_handle_adjacent_selectors
    input = <<END
div {
  color: blue;
  border: 1px solid green;
  + p {
    color: yellow;
    + b { font-variant: small-caps; }
  }
}
END
    
    output = <<END
div {
  color: blue;
  border: 1px solid green;
}
div + p {
  color: yellow;
}
div + p + b { font-variant: small-caps; }
END
    assert_equal output, process(input)
  end

  def test_should_handle_attribute_selectors
    input = <<END
div {
  color: blue;
  border: 1px solid green;
  [foo] { color: yellow; }
  [foo~="warning"] { color: blue; }
}
END
    
    output = <<END
div {
  color: blue;
  border: 1px solid green;
}
div[foo] { color: yellow; }
div[foo~="warning"] { color: blue; }
END

    assert_equal output, process(input)
  end

  def test_should_handle_comma_separated_selectors_without_nesting
    input = <<END
h1, h2, h3 {
  margin-top: 5px;
  color: red;
}
END
    assert_equal <<END, process(input)
h1 {
  margin-top: 5px;
  color: red;
}
h2 {
  margin-top: 5px;
  color: red;
}
h3 {
  margin-top: 5px;
  color: red;
}
END
  end

  def test_should_handle_comma_separated_selectors_with_outer_nesting
    input = <<END
h1, h2, h3 {
  margin-top: 5px;
  color: red;
  p { padding: 3px; }
}
END
    assert_equal <<END, process(input)
h1 {
  margin-top: 5px;
  color: red;
}
h1 p { padding: 3px; }
h2 {
  margin-top: 5px;
  color: red;
}
h2 p { padding: 3px; }
h3 {
  margin-top: 5px;
  color: red;
}
h3 p { padding: 3px; }
END
  end

  def test_should_handle_comma_separated_selectors_with_inner_nesting
    input = <<END
h1 {
  color: red;
  p, span { padding: 3px; }
}
END
    assert_equal <<END, process(input)
h1 {
  color: red;
}
h1 p {
  padding: 3px;
}
h1 span {
  padding: 3px;
}
END
  end

  def test_should_handle_comma_separated_selectors_with_deep_nesting
    input = <<END
div {
  color: red;
  h1 {
    color: blue;
    p, span {
      font-weight: strong;
    }
  }
}
END
    assert_equal <<END, process(input)
div {
  color: red;
}
div h1 {
  color: blue;
}
div h1 p {
  font-weight: strong;
}
div h1 span {
  font-weight: strong;
}
END
  end

  def test_should_handle_comma_separated_selectors_with_inner_and_outer_nesting
    input = <<END
div, span {
  color: red;
  h1, h2 {
    font-weight: strong;
  }
}
END
    assert_equal <<END, process(input)
div {
  color: red;
}
div h1 {
  font-weight: strong;
}
div h2 {
  font-weight: strong;
}
span {
  color: red;
}
span h1 {
  font-weight: strong;
}
span h2 {
  font-weight: strong;
}
END
  end

  def test_should_handle_comma_separated_selectors_on_subsequent_lines_inline_styles
    input = <<END
div#some,
div#another,
div#third { color: red; }
END
    assert_equal <<END, process(input)
div#some {
  color: red;
}
div#another {
  color: red;
}
div#third {
  color: red;
}
END
  end

  def test_should_handle_comma_separated_selectors_on_subsequent_lines_multiline_styles
    input = <<END
div#some,
div#another,
div#third {
  color: red;
}
END
    assert_equal <<END, process(input)
div#some {
  color: red;
}
div#another {
  color: red;
}
div#third {
  color: red;
}
END
  end

  def test_should_handle_comma_separated_fonts
    input = <<END
html, body {
  font-family: "Lucida Grande", Verdana, sans-serif;
}
END
    assert_equal <<END, process(input)
html {
  font-family: "Lucida Grande", Verdana, sans-serif;
}
body {
  font-family: "Lucida Grande", Verdana, sans-serif;
}
END
  end

  def test_should_handle_multiline_comments
    input = <<END
/*
 * Multilined comment outside a selector.
 */
html {
  /* 
   * Multilined comment inside a selector.
   */
  p {
     /*
     * And another one.
     */
    color: blue;
  }
}
END
    assert_equal <<END, process(input)
/*
 * Multilined comment outside a selector.
 */
html {
  /* 
   * Multilined comment inside a selector.
   */
}
html p {
  /*
  * And another one.
  */
  color: blue;
}
END
  end

  def test_should_handle_comments_with_blank_lines
    input = <<END
/*
 * This is a multiline comment.

 */
html {
  color: blue;
  /*
   * This is a multiline comment.

   */
  p {
    color: red;
  }
}
END
    assert_equal <<END, process(input)
/*
 * This is a multiline comment.

 */
html {
  color: blue;
  /*
   * This is a multiline comment.
   */
}
html p {
  color: red;
}
END
  end

  def test_should_handle_comments_with_commas
    input = <<END
/********************************************************* 
 Structural styling, sizing and positioning of elements
 ********************************************************/

* {
  margin: 0;
  padding: 0;
}

body {
  z-index: 2;
}
END
    assert_equal <<END, process(input)
/********************************************************* 
 Structural styling  sizing and positioning of elements
 ********************************************************/

* {
  margin: 0;
  padding: 0;
}

body {
  z-index: 2;
}
END
  end
end
