set :stage, :production

server 'sapphire.iicm.tugraz.at', user: 'sapphire', roles: %w{app db web}
