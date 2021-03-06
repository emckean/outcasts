require "rubygems"
require "bundler/setup"
require "twitter"
require "wordnik"
require "awesome_print"

Wordnik.configure do |config|
  config.api_key = ENV['WORDNIK_API_KEY']
  config.username = ENV['WORDNIK_USERNAME']
  config.password = ENV['WORDNIK_PASSWORD']
  config.logger = Logger.new('/dev/null')
end

Wordnik.authenticate

class Search
  
  attr_accessor :results
  
  def initialize(options={})
    @results = []
    defaults = {
      lang: "en",
      result_type: "recent",
      rpp: 100
    }
    options = defaults.merge(options)

    1.upto(15) do |page|
      options[:page] = page
      Twitter.search("is my favorite word", options).each do |_|
        result = Result.new(_.text)
        @results << result if result.valid?
      end
    end
    
    @results
  end
  
  def favorites
    @favorites = @results
    self.favorites = self.favorites.map do |favorite|
      response = Wordnik.word.get_word_forms(favorite, :useCanonical => 'true')
      raise response
      favorite = response['wordstring']
      raise favorite
    end
  end
  
  def favorites_as_request_object
    results.map do |_|
      {'word' => _.word}
    end
  end
  
end

class Result
  
  attr_accessor :text, :word, :favorite
  
  def initialize(text)
    self.text = text
    matches = self.text.scan(/\"?\'?([a-z|-]+)\"?\'? is my favorite word/i).flatten
    self.word = matches.first unless matches.empty?
  end
    
  def valid?
    word && word.size > 0
  end
  
  def has_dictionary_def?
    @has_dictionary_def ||= Wordnik.word.get_definitions(self.word, :limit => 1).size > 0
  end
  

    
end

class Reaper
  
  def self.run
    Wordnik.word_list.add_words_to_word_list(
      'favorites',
      Search.new.favorites_as_request_object,
      :username => Wordnik.configuration.username
    )
  end
  
end