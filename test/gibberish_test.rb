#coding: utf-8

begin
  require 'rubygems'
  require 'test/spec'
rescue LoadError
  puts "==> The test/spec library (gem) is required to run the Gibberish::Simple tests."
  exit
end

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'active_support'
require 'gibberish/simple'

Gibberish::Simple.language_paths << File.dirname(__FILE__) + '/..'
Gibberish::Simple.load_languages!

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
    string[:welcome_friend].should.not.equal string

    Gibberish::Simple.current_language = :fr
    string[:welcome_friend].should.not.equal string

    Gibberish::Simple.current_language = nil
    string[:welcome_friend].should.equal string
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
    string[:welcome_friend].should.equal string

    Gibberish::Simple.use_language :es do
      string[:welcome_friend].should.not.equal string
      Gibberish::Simple.should.not.be.default_language
    end

    Gibberish::Simple.should.be.default_language
    string[:welcome_friend].should.equal string
  end

  specify "should return an array of the languages it loaded" do
    languages = Gibberish::Simple.load_languages!
    languages.should.be.an.instance_of Array
    languages.should.include :es
    languages.should.include :fr
  end

  specify "should know what languages it has loaded" do
    languages = Gibberish::Simple.languages
    languages.should.be.an.instance_of Array
    languages.should.include :es
    languages.should.include :fr
  end

  specify "should be able to accept new, unique reserved keys" do
    key = :something_evil
    Gibberish::Simple.add_reserved_key key
    Gibberish::Simple.reserved_keys.should.include key
    Gibberish::Simple.reserved_keys.size.should.equal 2
    Gibberish::Simple.add_reserved_key key
    Gibberish::Simple.add_reserved_key key
    Gibberish::Simple.reserved_keys.size.should.equal 2
  end
  
  specify "should have loaded language files from directories other than the default" do
    Gibberish::Simple.language_paths << File.dirname(__FILE__)
    Gibberish::Simple.load_languages!
    string = "I don't speak Babble."
    Gibberish::Simple.use_language :es do
      string[:no_babble].should.equal "No hablo Bable."
    end
    Gibberish::Simple.use_language :fr do
      string[:no_babble].should.equal "Je ne parle pas Babble."
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

    string[:welcome_friend].should.equal string
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
    string[:welcome_friend].should.equal string
  end 
end

context "A gibberish string (in general)" do
  specify "should be a string" do
    "gibberish"[:just_a_string].should.be.an.instance_of String
    "non-gibberish".should.be.an.instance_of String
  end

  specify "should interpolate if passed arguments and replaces are present" do
    'Hi, {user} of {place}'[:hi_there, 'chris', 'france'].should.equal "Hi, chris of france"
    '{computer} omg?'[:puter, 'mac'].should.equal "mac omg?"
  end

  specify "should interpolate based on key if passed a hash" do
    'Hi, {user} of {place}'[:hi_there, { :place => 'france', :user => 'chris' }].should.equal "Hi, chris of france"

    bands  = { 'other_bad_band' => 'Deputy', :good_band => 'Word Picture', 'bad_band' => 'Dagger' }
    answer = 'Well, Dagger sucks and so does Deputy, but Word Picture is pretty rad.'
    'Well, {bad_band} sucks and so does {other_bad_band}, but {good_band} is pretty rad.'[:snobbish, bands].should.equal answer
  end

  specify "should not affect existing string methods" do
    string = "chris"
    answer = 'ch'
    string[0..1].should.equal answer
    string[0, 2].should.equal answer
    string[0].should.equal "c"
    string[/ch/].should.equal answer
    string['ch'].should.equal answer
    string['bc'].should.be.nil
    string[/dog/].should.be.nil
  end

  specify "should return nil if a reserved key is used" do
    "string"[:limit].should.be.nil
  end

  specify "should set default key to underscored string" do
    Gibberish::Simple.current_language = :es
    'welcome friend'[].should == "¡Bienvenido amigo!"
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
    string[:the_internet].should.equal string
  end

  specify "a gibberish string should return a translated version of itself if a corresponding key is found" do
    "Welcome, friend!"[:welcome_friend].should.equal '¡Bienvenido amigo!'
    "I love Rails."[:love_rails].should.equal "Amo los carriles."
    'Welcome, {user}!'[:welcome_user, 'Marvin'].should.equal '¡Bienvenido Marvin!'
  end
end
