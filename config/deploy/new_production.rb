set :rails_env, "production"

server 'newsapphire.isds.tugraz.at', user: 'sapphire', roles: %w{app db web}
