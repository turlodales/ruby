#!ruby -pla
BEGIN {
  require 'rubygems'
  date = nil
  if ENV.key?('GITHUB_OUTPUT')
    output = File.open(ENV['GITHUB_OUTPUT'], 'w')
  else
    output = STDERR
  end
}
END {
  output.print date.strftime("latest_date=%F") if date
}
unless /^[^#]/ !~ (gem = $F[0])
  (gem, src), = Gem::SpecFetcher.fetcher.detect(:latest) {|s|
    s.platform == "ruby" && s.name == gem
  }
  gem = src.fetch_spec(gem)
  if ENV["UPDATE_BUNDLED_GEMS_ALL"]
    uri = gem.metadata["source_code_uri"] || gem.homepage
    uri = uri.sub(%r[\Ahttps://github\.com/[^/]+/[^/]+\K/tree/.*], "").chomp(".git")
  else
    uri = $F[2]
  end
  date = gem.date if !date or gem.date && gem.date > date
  if $F[3]
    if $F[3].include?($F[1])
      $F[3][$F[1]] = gem.version.to_s
    elsif Gem::Version.new($F[1]) != gem.version and /\A\h+\z/ =~ $F[3]
      $F[3..-1] = []
    end
  end
  f = [gem.name, gem.version.to_s, uri, *$F[3..-1]]
  $_.gsub!(/\S+\s*/) {|s| (f.shift || "").ljust(s.size)}
  $_ = [$_, *f].join(" ") unless f.empty?
  $_.rstrip!
end
