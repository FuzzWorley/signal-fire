class ChatPlatformValidator
  ALLOWED_PATTERNS = {
    "whatsapp" => /\Ahttps:\/\/chat\.whatsapp\.com\//,
    "discord"  => /\Ahttps:\/\/(discord\.gg|discord\.com\/invite)\//,
    "telegram" => /\Ahttps:\/\/t\.me\//,
    "signal"   => /\Ahttps:\/\/signal\.group\//,
    "groupme"  => /\Ahttps:\/\/groupme\.com\//,
    "slack"    => /\Ahttps:\/\/[\w-]+\.slack\.com\/join\//,
  }.freeze

  def self.valid?(platform, url)
    pattern = ALLOWED_PATTERNS[platform.to_s]
    return false unless pattern
    url.to_s.match?(pattern)
  end

  def self.pattern_hint(platform)
    {
      "whatsapp" => "https://chat.whatsapp.com/...",
      "discord"  => "https://discord.gg/... or https://discord.com/invite/...",
      "telegram" => "https://t.me/...",
      "signal"   => "https://signal.group/...",
      "groupme"  => "https://groupme.com/...",
      "slack"    => "https://your-workspace.slack.com/join/...",
    }[platform.to_s]
  end
end
