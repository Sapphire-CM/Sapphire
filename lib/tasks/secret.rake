namespace :secret do

  desc "Updates the secret"
  task :update do
    # stolen from: github.com/digineo/secret_token_replacer/

    pattern  = /(\.secret_token *= *')\w+(')/
    secret   = SecureRandom.hex(64)
    filepath = "#{Rails.root}/config/initializers/secret_token.rb"
    content  = File.read(filepath)

    # replace the secret token
    content.gsub!(pattern,"\\1#{secret}\\2")

    # write the new configuration
    File.open(filepath, 'w') {|f| f.write(content) }
  end

end