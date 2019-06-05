require 'slack-ruby-client'
require 'yaml'

config = YAML.load_file('config.yml')
SLACK_TOKEN = config['token']

Slack.configure do |config|
  config.token = SLACK_TOKEN
end

$client = Slack::Web::Client.new
$client.auth_test

$n = File.new("size.txt").gets.to_i

def inc_size
  $n += 1
  File.open("size.txt", "w") do |f|
    f.puts($n.to_s)
  end
end

def post_list(list)
  $client.chat_postMessage(channel: '#sort-algorithms', text: list.to_s, as_user: true)
end

def post_algo(algo)
  $client.chat_postMessage(channel: '#sort-algorithms', text: "#{algo.name}, n=#{$n}", as_user: true)
end

class SortMachine
  def sort(list)
    raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
  end
end

class BubbleSort < SortMachine
  def sort(list)
    n = list.length
    n.times do |i|
      (n-i-1).times do |j|
        if list[j] > list[j+1] then
          list[j], list[j+1] = list[j+1], list[j]
        end
        yield list
      end
    end
    list
  end
end

class QuickSort < SortMachine
  def sort(list)
    if list.length < 2 then
      yield list
      return list
    end
    if list.length == 2 then
      if list[0] > list[1] then
        list[0], list[1] = list[1], list[0]
      end
      yield list
      return list
    end
    copy = Array.new(list)
    pivot = copy.shift
    larges = []
    smalls = []
    copy.each {|e|
      if e > pivot then
        larges.push(e)
      else
        smalls.push(e)
      end
    }
    yield smalls + [pivot] + larges
    smalls = sort(smalls) {|tmp|
      yield tmp + [pivot] + larges
    }
    larges = sort(larges) {|tmp|
      yield smalls + [pivot] + tmp
    }
    smalls + [pivot] + larges
  end
end

$algorithms = [BubbleSort, QuickSort]

loop do
  $algorithms.each {|algo|
    post_algo(algo)
    obj = algo.new
    list = Array.new($n) {|i| i}
    list.shuffle!
    post_list(list)
    sleep(60)
    obj.sort(list) {|tmp|
      post_list(tmp)
      sleep(60)
    }
  }
  inc_size
end
