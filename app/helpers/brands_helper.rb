module BrandsHelper
  def redirect_types(type,brand)
    case type
    when 'twitter'
      "http://twitter.com/" + brand.twitter
    when 'website'
      brand.website
    when 'facebook'
      brand.facebook
    when 'instagram'
      "http://instagram.com/" + brand.instagram
    end
  end
end
