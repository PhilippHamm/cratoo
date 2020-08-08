require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, "f89128215edc44adb16bfe8fb2aba93d", "05678f9267a04d7daaa62f208d2f062c", scope: 'playlist-modify-public'
end
