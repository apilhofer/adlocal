# frozen_string_literal: true

require 'mini_magick'
require 'net/http'
require 'uri'

class ImageCompositorService
  def initialize(generated_ad)
    @generated_ad = generated_ad
    @campaign = generated_ad.campaign
    @business = @campaign.business
  end

  def composite
    Rails.logger.info "Starting image composition for ad #{@generated_ad.id}"
    
    begin
      # Download background image
      background_image = download_background_image
      
      # Load business logo
      logo_image = load_business_logo
      
      # Resize/crop background to ad size dimensions
      background_image = resize_background(background_image)
      
      # Composite elements onto background
      composite_image = composite_elements(background_image, logo_image)
      
      # Save final image to Active Storage
      final_image_url = save_final_image(composite_image)
      
      # Update GeneratedAd with final image URL
      @generated_ad.update!(
        final_image_url: final_image_url,
        is_locked: true
      )
      
      Rails.logger.info "Successfully composed image for ad #{@generated_ad.id}"
      final_image_url
      
    rescue => e
      Rails.logger.error "Failed to composite image for ad #{@generated_ad.id}: #{e.message}"
      raise e
    end
  end

  private

  def download_background_image
    Rails.logger.info "Downloading background image from: #{@generated_ad.background_image_url}"
    
    uri = URI(@generated_ad.background_image_url)
    response = Net::HTTP.get_response(uri)
    
    unless response.is_a?(Net::HTTPSuccess)
      raise "Failed to download background image: #{response.code} #{response.message}"
    end
    
    # Create temporary file
    temp_file = Tempfile.new(['background', '.png'])
    temp_file.binmode
    temp_file.write(response.body)
    temp_file.rewind
    
    MiniMagick::Image.open(temp_file.path)
  end

  def load_business_logo
    return nil unless @business.logo.attached?
    
    Rails.logger.info "Loading business logo"
    
    # Download logo from Active Storage
    logo_blob = @business.logo.blob
    temp_file = Tempfile.new(['logo', '.png'])
    temp_file.binmode
    temp_file.write(logo_blob.download)
    temp_file.rewind
    
    MiniMagick::Image.open(temp_file.path)
  end

  def resize_background(background_image)
    # Get ad size dimensions
    width, height = @generated_ad.ad_size.split('x').map(&:to_i)
    
    Rails.logger.info "Resizing background to #{width}x#{height}"
    
    # Resize and crop background to exact ad dimensions
    background_image.resize("#{width}x#{height}^")
    background_image.gravity('center')
    background_image.extent("#{width}x#{height}")
    
    background_image
  end

  def composite_elements(background_image, logo_image)
    positions = @generated_ad.element_positions
    
    # Composite logo if present
    if logo_image && positions['logo']
      logo_pos = positions['logo']
      logo_image.resize("#{logo_pos['width']}x#{logo_pos['height']}")
      background_image = background_image.composite(logo_image) do |c|
        c.compose "Over"
        c.geometry "+#{logo_pos['x']}+#{logo_pos['y']}"
      end
    end
    
    # Draw headline text
    if positions['headline']
      headline_pos = positions['headline']
      background_image = draw_text(
        background_image,
        @generated_ad.headline,
        headline_pos['x'],
        headline_pos['y'],
        headline_pos['fontSize'],
        headline_pos['color'],
        headline_pos['align']
      )
    end
    
    # Draw subheadline text
    if positions['subheadline']
      subheadline_pos = positions['subheadline']
      background_image = draw_text(
        background_image,
        @generated_ad.subheadline,
        subheadline_pos['x'],
        subheadline_pos['y'],
        subheadline_pos['fontSize'],
        subheadline_pos['color'],
        subheadline_pos['align']
      )
    end
    
    # Draw CTA button
    if positions['cta']
      cta_pos = positions['cta']
      # Draw button background
      background_image = draw_button_background(
        background_image,
        cta_pos['x'],
        cta_pos['y'],
        cta_pos['width'],
        cta_pos['height'],
        cta_pos['bgColor']
      )
      
      # Draw CTA text
      background_image = draw_text(
        background_image,
        @generated_ad.call_to_action,
        cta_pos['x'] + cta_pos['width'] / 2,
        cta_pos['y'] + cta_pos['height'] / 2,
        cta_pos['fontSize'],
        cta_pos['color'],
        'center'
      )
    end
    
    background_image
  end

  def draw_text(image, text, x, y, font_size, color, align)
    image.combine_options do |c|
      c.font "Arial-Bold"
      c.pointsize font_size
      c.fill color
      c.gravity case align
                when 'left' then 'NorthWest'
                when 'center' then 'North'
                when 'right' then 'NorthEast'
                else 'North'
                end
      c.draw "text #{x},#{y} '#{text}'"
    end
    
    image
  end

  def draw_button_background(image, x, y, width, height, bg_color)
    image.combine_options do |c|
      c.fill bg_color
      c.draw "rectangle #{x},#{y} #{x + width},#{y + height}"
    end
    
    image
  end

  def save_final_image(image)
    Rails.logger.info "Saving final composite image"
    
    # Create a blob for the final image
    temp_file = Tempfile.new(['final_ad', '.png'])
    image.write(temp_file.path)
    
    # Attach to GeneratedAd
    @generated_ad.final_image.attach(
      io: File.open(temp_file.path),
      filename: "ad_#{@generated_ad.id}_#{@generated_ad.ad_size}.png",
      content_type: 'image/png'
    )
    
    # Return the URL
    Rails.application.routes.url_helpers.rails_blob_url(@generated_ad.final_image, host: Rails.application.config.action_mailer.default_url_options[:host])
  end
end
