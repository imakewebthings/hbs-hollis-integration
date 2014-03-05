require 'json'
require 'open-uri'

namespace :lcsh do
  LC_ENDPOINT = 'http://hlslwebtest.law.harvard.edu/v1/api/item/?filter=collection:hollis_catalog,hbs_edu'

  desc 'Find LCSH exact matches for Topics'
  task :exact => :environment do
    Rails.logger.level = Logger::ERROR
    topics = Topic.where(lcsh: nil).pluck(:name, :slug)
    hit_count = 0
    miss_count = 0
    topics.each do |topic|
      topic_name = topic.first
      lcsh_name = topic_name.humanize + '.'
      query = CGI::escape lcsh_name
      url = LC_ENDPOINT + "&filter=lcsh:#{query}"
      response = JSON.parse open(url).read
      if response['num_found'].nonzero?
        hit_count += 1
        puts "#{topic_name} -> #{lcsh_name}"
        Topic.find_by_slug(topic.last).update(lcsh: lcsh_name) 
      else
        miss_count += 1
      end
    end
    puts "\nEXACT: #{hit_count} hits. #{miss_count} misses."
  end

  desc 'Exact match of word components'
  task :component => :environment do
    Rails.logger.level = Logger::ERROR
    topics = Topic.where(lcsh: nil).pluck(:name, :slug)
    hit_count = 0
    topics.each do |topic|
      topic_components = topic.first.split(',').map do |str|
        str.split(' and ')
      end.flatten.reject(&:empty?).map(&:strip)
      next if topic_components.length == 1
      found = false
      topic_components.each do |component|
        lcsh_name = component.humanize + '.'
        query = CGI::escape lcsh_name
        url = LC_ENDPOINT + "&filter=lcsh:#{query}"
        response = JSON.parse open(url).read
        if response['num_found'].nonzero?
          found = true
          puts "#{topic.first} -> #{lcsh_name}"
          Topic.find_by_slug(topic.last).update(lcsh: lcsh_name) 
          break
        end
      end
      if found
        hit_count += 1
      end
    end
    puts "\nCOMPONENT: #{hit_count} more matches found"
  end

  desc 'Generate best-guess LCSH matches for Topics'
  task :match => :environment do
    Rails.logger.level = Logger::ERROR
    topics = Topic.where(lcsh: nil).pluck(:name, :slug)
    hit_count = 0
    miss_count = 0
    topics.each do |topic|
      query = CGI::escape topic.first
      slug = topic.last
      docs = []
      url = [
        LC_ENDPOINT,
        "filter=subject_keyword:#{query}",
        "filter=format:Book",
        "limit=250"
      ].join('&')
      2.times do |page|
        response = JSON.parse open("#{url}&start=#{page*250}").read
        docs.concat response['docs']
      end
      lcsh_freq = docs.reduce(Hash.new(0)) do |memo, item|
        if item['lcsh']
          item['lcsh'].each do |subject|
            next if subject['HKS Faculty'] || subject['CD-ROMs']
            memo[subject] += 1
          end
        end
        memo
      end.sort_by{|k, v| -v }.slice(0, 50)
      if lcsh_freq && lcsh_freq.length > 0
        hit_count += 1
      else
        miss_count += 1
        next
      end
      most_common = lcsh_freq.max_by do |lcsh|
        lcsh_words = lcsh.first
          .downcase
          .gsub(/\b(and|or|of|in|the)\b/, ' ')
          .gsub(/\W/, ' ')
          .split(' ')
          .map(&:singularize)
        topic_words = topic.first
          .downcase
          .gsub(/\b(and|or|of|in|the)\b/, ' ')
          .split(' ')
          .map(&:singularize)
        common_word_count = (lcsh_words & topic_words).length
        has_common_words = common_word_count > 0 ? 1 : 0;
        uncommon_word_count = (lcsh_words + topic_words).length - common_word_count
        no_uncommon_words = uncommon_word_count > 0 ? 0 : 1;
        result_count = lcsh.last
        #puts "#{common_word_count} / #{uncommon_word_count} / #{result_count} / #{lcsh.first}"
        [
          has_common_words,
          no_uncommon_words,
          common_word_count - uncommon_word_count,
          result_count
        ]
      end
      best_match = most_common.first
      puts "#{topic.first} -> #{best_match}"
      #Topic.find_by_slug(slug).update(lcsh: best_match)
    end
    puts "\nFUZZY MATCH: #{hit_count} hits. #{miss_count} left unmatched."
  end
end
