require 'helper'

class OTSTest < Test::Unit::TestCase

  SAMPLE = <<-TEXT
    The hawksbill turtle is a critically endangered sea turtle belonging to the family Cheloniidae.
    It is the only species in its genus. The species has a worldwide distribution, with Atlantic and
    Pacific subspecies.
  TEXT

  context 'Title' do
    should 'extract title from given document' do
      ots = OTS.new
      ots.parse SAMPLE
      assert_equal 'species,turtle,subspecies,pacific,atlantic', ots.title
    end
  end

  context 'Keywords' do
    should 'extract keywords from given document' do
      ots = OTS.new
      ots.parse SAMPLE
      assert_equal %W(
        species turtle subspecies pacific atlantic distribution worldwide genus cheloniidae family
        belonging sea endangered critically hawksbill
      ), ots.keywords
    end
  end

  context 'Summary' do
    should 'extract keywords from given document' do
      ots = OTS.new
      ots.parse SAMPLE
      lines = ots.summarize(:lines => 2).map do |value|
        { :sentence => value[:sentence].gsub(/\n\s*/, ' ').strip, :score => value[:score] }
      end

      assert_equal [
        {
          :sentence => "The hawksbill turtle is a critically endangered sea turtle belonging to the family Cheloniidae.",
          :score    => 48
        },
        {
          :sentence => "The species has a worldwide distribution, with Atlantic and Pacific subspecies.",
          :score    => 20
        }
      ], lines

    end

    should 'utf8 encode strings properly' do
      ots = OTS.new
      text = "The hawksbill turtle\xE2\x80\x93is critically endangered."
      text.force_encoding('UTF-8') if RUBY_VERSION >= "1.9"

      ots.parse(text)
      summary = ots.summarize(:lines => 1).first[:sentence]
      assert_equal text, summary
    end
  end

end
