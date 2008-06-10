require 'action_view/helpers/asset_tag_helper'
require 'ostruct'

# Monkey patch to enable CssDryer to work with rails asset caching.
module ActionView::Helpers::AssetTagHelper
  private

  # Returns the full path for the given stylesheet according to application
  # conventions.  Optionally, may return a set of assigns that will be used
  # when rendering the stylesheet during asset packing.
  def ncss_stylesheet_location(path)
    File.join(RAILS_ROOT, "app", "views", path).gsub(/\.css$/, ".ncss")
  end

  # Enhances the :all expansion to include dynamic stylesheets in addition
  # to the static ones.
  def expand_stylesheet_sources_with_ncss(sources)
    if sources.first == :all
      @@all_javascript_sources ||= (
        expand_stylesheet_sources_without_ncss(sources) +
        Dir[File.join(RAILS_ROOT, "app", "views", "stylesheets", "*.ncss")].collect { |file| File.basename(file).gsub(/\.\w+$/, '') }
        ).sort
    else
      expand_stylesheet_sources_without_ncss(sources)
    end
  end
  alias_method_chain :expand_stylesheet_sources, :ncss

  # Calls CssDryer to render a dynamic stylesheet.
  def ncss_stylesheet_contents(path)
    full_path, assigns = ncss_stylesheet_location(path)
    template = File.read(full_path)
    view = OpenStruct.new(:assigns => (assigns || {}), :headers => {})
    view.controller = view
    handler = CssDryer::NcssHandler.new(view)
    handler.render(template, {})
  end

  # Returns the contents of the given path.  If the path refers to a
  # nonexistant stylesheet, it will render the contents via CssDryer.
  def asset_file_contents(path)
    path = path.split("?").first
    full_path = File.join(ASSETS_DIR, path)
    if !File.exists?(full_path) && File.extname(path) == ".css"
      ncss_stylesheet_contents(path)
    else
      File.read(full_path)
    end
  end

  # Adjusted to call asset_file_contents instead of assuming a file exists.
  def join_asset_file_contents(paths)
    paths.collect { |path| asset_file_contents(path) }.join("\n\n")
  end
end
