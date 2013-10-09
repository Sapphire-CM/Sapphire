set :stage, :staging

server 'stagingsapphire.iicm.tugraz.at', user: 'sapphire', roles: %w{app db web}
