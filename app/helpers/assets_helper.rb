module AssetsHelper
  # returns an image tag for given asset and size
  def asset_image_tag(asset, size)
    if asset.image?
      image_tag asset.public_filename(size)
    else
      glyph('page_white')
    end
  end
  
  # renders partial for given asset based on
  # type of asset 
  def asset_view(asset)
    partial = case
      when asset.image? : 'image'
      when asset.zip?   : 'zip'
    end
    
    render :partial => partial, :object => asset unless partial.nil?
  end
end
