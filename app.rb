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
      'ASSEMBLY_DATASOURCE',
      'Update ASSEMBLY_DATASOURCE',
      datasource_url(assembly_sha),
      branch: 'master'
    )
    github.create_contents(
      'mysociety/kuvakazim',
      'SENATE_DATASOURCE',
      'Update SENATE_DATASOURCE',
      datasource_url(senate_sha),
      branch: 'master'
    )
  end

  private

  def github
    @github ||= Octokit::Client.new(access_token: GITHUB_ACCESS_TOKEN)
  end

  def datasource_url(sha)
    "https://cdn.rawgit.com/everypolitician/everypolitician-data/#{sha}/" \
      "data/Zimbabwe/Assembly/ep-popolo-v1.0.json\n"
  end

  def assembly_sha
    assembly = zimbabwe[:legislatures].find { |l| l[:slug] == 'Assembly' }
    assembly[:sha]
  end

  def senate_sha
    senate = zimbabwe[:legislatures].find { |l| l[:slug] == 'Senate' }
    senate[:sha]
  end

  def zimbabwe
    @zimbabwe ||= countries.find { |c| c[:slug] == 'Zimbabwe' }
  end

  def countries
    @countries ||= JSON.parse(open(countries_url).read, symbolize_names: true)
  end

  def countries_url
    'https://raw.githubusercontent.com/everypolitician/everypolitician-data/' \
      'master/countries.json'
  end
end
