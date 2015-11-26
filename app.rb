require 'json'
require 'open-uri'

require 'webhook_handler'
require 'octokit'
require 'dotenv'
Dotenv.load

# Webhook handler which updates the KuvakaZim Jekyll site's DATASOURCE file
class KuvakazimUpdater
  include WebhookHandler

  begin
    GITHUB_ACCESS_TOKEN = ENV.fetch('GITHUB_ACCESS_TOKEN')
  rescue KeyError => e
    abort "Please set the GITHUB_ACCESS_TOKEN environment variable: #{e}"
  end

  def perform
    github.create_contents(
      'mysociety/kuvakazim',
      'DATASOURCE',
      'Update DATASOURCE',
      datasource_url,
      branch: 'master'
    )
  end

  private

  def github
    @github ||= Octokit::Client.new(access_token: GITHUB_ACCESS_TOKEN)
  end

  def datasource_url
    "https://cdn.rawgit.com/everypolitician/everypolitician-data/#{sha}/" \
      "data/Zimbabwe/Assembly/ep-popolo-v1.0.json\n"
  end

  def sha
    countries = JSON.parse(open(countries_url).read, symbolize_names: true)
    zimbabwe = countries.find { |c| c[:slug] == 'Zimbabwe' }
    # FIXME: This only handles the Assembly at the moment.
    assembly = zimbabwe[:legislatures].find { |l| l[:slug] == 'Assembly' }
    assembly[:sha]
  end

  def countries_url
    'https://raw.githubusercontent.com/everypolitician/everypolitician-data/' \
      'master/countries.json'
  end
end
