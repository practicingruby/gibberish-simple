#coding: utf-8

begin
  require 'rubygems'
  require 'test/spec'
rescue LoadError
  puts "==> The test/spec library (gem) is required to run the Gibberish::Simple tests."
  exit
end

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'gibberish/simple'

Gibberish::Simple.language_paths << File.dirname(__FILE__) + '/..'
Gibberish::Simple.load_languages!

include Gibberish::Simple

context "After loading languages, Gibberish::Simple" do
  teardown do
    Gibberish::Simple.current_language = nil
  end

  specify "should know what languages it has translations for" do
    Gibberish::Simple.languages.should.include :es
  end

  specify "should know if it is using the default language" do
    Gibberish::Simple.should.be.default_language
  end

  specify "should be able to switch between existing languages" do
    Gibberish::Simple.current_language = :es
    string = "Welcome, friend!"
    T(string, :welcome_friend).should.not.equal string

    Gibberish::Simple.current_language = :fr
    T(string, :welcome_friend).should.not.equal string

    Gibberish::Simple.current_language = nil
    T(string, :welcome_friend).should.equal string
  end

  specify "should be able to switch languages using strings" do
    Gibberish::Simple.current_language = 'es'
    Gibberish::Simple.current_language.should.equal :es
  end

  specify "should be able to switch to the default language at any time" do
    Gibberish::Simple.current_language = :fr
    Gibberish::Simple.should.not.be.default_language

    Gibberish::Simple.current_language = nil
    Gibberish::Simple.should.be.default_language
  end

  specify "should be able to switch to a certain language for the duration of a block" do
    Gibberish::Simple.should.be.default_language

    string = "Welcome, friend!"
    T(string, :welcome_friend).should.equal string

    Gibberish::Simple.use_language :es do
      T(string, :welcome_friend).should.not.equal string
      Gibberish::Simple.should.not.be.default_language
    end

    Gibberish::Simple.should.be.default_language
    T(string, :welcome_friend).should.equal string
  end

  specify "should return an array of the languages it loaded" do
    languages = Gibberish::Simple.load_languages!
    languages.should.be.an.instance_of Array
    languages.should.include :es
    languages.should.include :fr
  end

  specify "should know what languages it has loaded" do
    languages = Gibberish::Simple.language_names
    languages.should.be.an.instance_of Array
    languages.should.include :es
    languages.should.include :fr
  end

  specify "should have loaded language files from directories other than the default" do
    Gibberish::Simple.language_paths << File.dirname(__FILE__)
    Gibberish::Simple.load_languages!
    string = "I don't speak Babble."
    Gibberish::Simple.use_language :es do
      T(string, :no_babble).should.equal "No hablo Bable."
    end
    Gibberish::Simple.use_language :fr do
      T(string, :no_babble).should.equal "Je ne parle pas Babble."
    end
  end
end

context "When no language is set" do
  setup do
    Gibberish::Simple.current_language = nil
  end

  specify "the default language should be used" do
    Gibberish::Simple.current_language.should.equal Gibberish::Simple.default_language
  end

  specify "a gibberish string should return itself" do
    string = "Welcome, friend!"
    Gibberish::Simple.translate(string, :welcome_friend).should.equal string

    T(string, :welcome_friend).should.equal string
  end
end

context "When a non-existent language is set" do
  setup do
    Gibberish::Simple.current_language = :klingon
  end

  specify "the default language should be used" do
    Gibberish::Simple.current_language.should.equal Gibberish::Simple.default_language
  end

  specify "gibberish strings should return themselves" do
    string = "something gibberishy"
    T(string, :welcome_friend).should.equal string
  end 
end

context "A translated string (in general)" do
  specify "should be a string" do
    T("gibberish", :just_a_string).should.be.an.instance_of String
    "non-gibberish".should.be.an.instance_of String
  end

  specify "should interpolate if passed arguments and replaces are present" do
    T('Hi, {user} of {place}', :hi_there, 'chris', 'france').should.equal "Hi, chris of france"
    T('{computer} omg?', [:puter, 'mac']).should.equal "mac omg?"
  end

  specify "should interpolate based on key if passed a hash" do
    T('Hi, {user} of {place}', [:hi_there, { :place => 'france', :user => 'chris' }]).should.equal "Hi, chris of france"

    bands  = { 'other_bad_band' => 'Deputy', :good_band => 'Word Picture', 'bad_band' => 'Dagger' }
    answer = 'Well, Dagger sucks and so does Deputy, but Word Picture is pretty rad.'
    T('Well, {bad_band} sucks and so does {other_bad_band}, but {good_band} is pretty rad.', :snobbish, bands).should.equal answer
  end

end

context "When a non-default language is set" do
  setup do
    Gibberish::Simple.current_language = :es
  end

  specify "that language should be used" do
    Gibberish::Simple.current_language.should.equal :es
  end

  specify "the default language should not be used" do
    Gibberish::Simple.should.not.be.default_language
  end

  specify "a gibberish string should return itself if a corresponding key is not found" do
    string = "The internet!"
    T(string, :the_internet).should.equal string
  end

  specify "a gibberish string should return a translated version of itself if a corresponding key is found" do
    T("Welcome, friend!", :welcome_friend).should.equal '¡Bienvenido amigo!'
    T("I love Rails.", :love_rails).should.equal "Amo los carriles."
    T('Welcome, {user}!', :welcome_user, 'Marvin').should.equal '¡Bienvenido Marvin!'
  end
end
