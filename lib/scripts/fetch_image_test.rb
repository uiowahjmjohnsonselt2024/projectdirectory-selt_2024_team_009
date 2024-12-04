require "openai"

def generate_image(prompt)
  begin
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    response = client.images.generate(
      parameters: {
        model: "dall-e-3",  # Latest DALL-E model
        prompt: prompt,
        size: "1024x1024",  # Options: "1024x1024", "1792x1024", or "1024x1792"
        quality: "standard", # Options: "standard" or "hd"
        n: 1                # Number of images to generate
      }
    )

    # Extract the image URL from the response
    image_url = response.dig("data", 0, "url")
    puts "Generated Image URL: #{image_url}"

    # You could download the image here if needed
    image_url

  rescue OpenAI::Error => e
    puts "OpenAI Error: #{e.class} - #{e.message}"
    nil
  rescue StandardError => e
    puts "Unexpected Error: #{e.class} - #{e.message}"
    nil
  end
end

# Test the environment variable
puts "API Key present: #{!ENV['OPENAI_API_KEY'].nil?}"

# Generate an image
prompt = "A majestic cat wearing a golden crown, digital art style"
result = generate_image(prompt)
puts "Result: #{result || 'No image generated'}"

# Optional: Download the image if you want to save it locally
if result
  require 'open-uri'
  require 'securerandom'

  begin
    filename = "generated_image_#{SecureRandom.hex(4)}.png"
    URI.open(result) do |image|
      File.open(filename, "wb") do |file|
        file.write(image.read)
      end
    end
    puts "Image saved as: #{filename}"
  rescue StandardError => e
    puts "Error saving image: #{e.message}"
  end
end