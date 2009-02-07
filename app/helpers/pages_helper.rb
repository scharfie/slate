module PagesHelper
  # Returns glyph for given page
  def page_glyph(page)
    return glyph('house') if page.default?
    return glyph('cog') if page.mount?
    glyph('page_white')
  end
end
