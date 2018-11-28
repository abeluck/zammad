require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'rest-client'

class SigarilloAPI
  def initialize(api_url, token)
    @token = token
    @last_update = 0
    @api = api_url
  end

  def parse_hash(hash)
    ret = {}
    hash.map do |k, v|
      ret[k] = URI::encode(v.to_s.gsub('\\\'', '\''))
    end
    ret
  end

  def get(api)
    url = @api + '/bot/' + @token + '/' + api
    ret = JSON.parse(RestClient.get(url, {accept: :json}).body)
    ret
  end

  def post(api, params = {})
    url = @api + '/bot/' + @token + '/' + api
    ret = JSON.parse(RestClient.post(url, params, {accept: :json}).body)
    ret
  end

  def get_me
    self.get('')
  end

  def send_message(to, text, options = {})
    self.post('send', {:recipient => to.to_s, :message => text}.merge(parse_hash(options)))
  end

  def fetch
    results = self.get('receive')
    if results['messages'].nil?
      Rails.logger.error {'sigarillo fetch failed'}
      Rails.logger.debug {results.inspect}
      return []
    end

    messages = results['messages']
    return messages
  end
end