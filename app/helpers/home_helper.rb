module HomeHelper
end


# app/services/image_generator.rb

require 'openai'

class ImageGenerator
  def self.generate_image(prompt)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    begin
      response = client.images.generate(
        parameters: {
          prompt: prompt,
          model: "dall-e-3",
          size: "512x512",
          n: 1
        }
      )

      if response.dig("data", 0, "url").present?
        image_url = response["data"][0]["url"]
        Rails.logger.info "Generated Image URL: #{image_url}"
        return image_url
      else
        Rails.logger.error "DALL-E did not return an image URL: #{response.inspect}"
        return nil
      end
    rescue StandardError => e
      Rails.logger.error "Error generating DALL-E image: #{e.message}"
      return nil
    end
  end
end
