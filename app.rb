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
    assembly_datasource = github.contents('mysociety/kuvakazim', path: 'ASSEMBLY_DATASOURCE')
    senate_datasource = github.contents('mysociety/kuvakazim', path: 'SENATE_DATASOURCE')
    github.update_contents(
      'mysociety/kuvakazim',
      'ASSEMBLY_DATASOURCE',
      'Update ASSEMBLY_DATASOURCE',
      assembly_datasource[:sha],
      datasource_url(assembly),
      branch: 'master'
    )
    github.update_contents(
      'mysociety/kuvakazim',
      'SENATE_DATASOURCE',
      'Update SENATE_DATASOURCE',
      senate_datasource[:sha],
      datasource_url(senate),
      branch: 'master'
    )
  end

  private

  def github
    @github ||= Octokit::Client.new(access_token: GITHUB_ACCESS_TOKEN)
  end

  def datasource_url(house)
    "https://cdn.rawgit.com/everypolitician/everypolitician-data/#{house[:sha]}/" \
      "#{house[:popolo]}\n"
  end

  def assembly
    @assembly ||= zimbabwe[:legislatures].find { |l| l[:slug] == 'Assembly' }
  end

  def senate
    @senate ||= zimbabwe[:legislatures].find { |l| l[:slug] == 'Senate' }
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
