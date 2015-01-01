require 'rubygems'

def make_sentenses(text)
    words = text.split(/\s+/)
    sentenses = []
    sentense  = []
    words.each do |word|
        sentense << word
        if word =~ /(\.|\?)$/
            sentenses << sentense 
            sentense = []
        end
    end
    if sentense.length > 0
        sentenses << sentense
    end
    sentenses.uniq!
    sentenses
end

def clean_words(words)
    words.map{|word| word.downcase.gsub(/[^a-z0-9]+/, '')}
end

def score(src_words, dst_words)
    src_words = clean_words(src_words)
    dst_words = clean_words(dst_words)
    common_words = src_words & dst_words
    all_words  = src_words | dst_words
    all_words.length == 0 ? 0 : (common_words.length*1.0/all_words.length)
end

def score_sentenses(sentenses)
    scores = []
    sentenses.each_with_index do |src_sentense, src_index|
        scores[src_index] = 0
        sentenses.each_with_index do |dst_sentense, dst_index|
            if src_index != dst_index
                scores[src_index] += score(src_sentense, dst_sentense)
            end
        end
    end
    scores.each_with_index.map do |score, index| 
        {words: sentenses[index], score: score}
    end
end

def summarize(text, num_sentenses=5)
    sentenses = make_sentenses(text)
    sentenses = score_sentenses(sentenses).sort_by{|s| s[:score]*-1}
    puts sentenses.first(num_sentenses).map{|sentense| sentense[:words].join(" ")}.join(" ")
end

text = open("sample.txt").read
summarize(text)
