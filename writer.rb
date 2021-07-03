class Story
  attr_accessor :text
  def initialize(text_file)
    @text = text_file
  end

  def tokenize(sentence)
    sentence.downcase.split(/[^a-z]+/).reject(&:empty?).map(&:to_sym)
  end

  def pick_next_word_weighted_randomly(head, stats)
    continuations = stats[head]
    continuations.flat_map {|word, count| [word] * count}.sample
  end

  def create_story(word_count, neighbor_count)
    text = tokenize(IO.read(@text))
    stats = {}

    text.each_cons(neighbor_count) do |*head, continuation|
      stats[head] ||= Hash.new(0)

      stats[head][continuation] += 1
    end

    story = stats.keys.sample

    1.upto(word_count) do
      story << pick_next_word_weighted_randomly(story.last(neighbor_count - 1), stats)
    end

    puts story.join(" ")
  end
end

def main
  if ARGV.length != 2
    puts "Enter a text file and the number of words you want your story to be.\n"
    puts "Example usage: ruby writer.rb file.txt 100"
  else
    file = ARGV.first
    begin
      story = Story.new(file)
      story.create_story(ARGV.last.to_i, 6)
    rescue => exception
      puts "Example usage: ruby writer.rb file.txt 100"
    end
  end
end

main