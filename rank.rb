require 'rubygems'

=begin
I was able to verify results are accurate if all weights are equal. 
But in general it works even if the weights are different.
I am no expert. Don't mix this in your secret sauce. 
=end

class WeightedPageRank

    def initialize(edges)
        @edges = edges
        @damping = 0.85
    end

    def rank()
        node_count = @edges.map{|e| [e[0], e[1]]}.flatten.uniq.count
        node_info = {}
        total_weight = {}

        @edges.each do |edge|
            total_weight[edge[0]] ||= 0
            total_weight[edge[0]]  += edge[2]
        end

        @edges.each do |edge|
            src = edge[0]
            dst = edge[1]
            weight = edge[2]*1.0
            node_info[src] ||= {}
            node_info[src][:outgoing] ||= 0
            node_info[src][:outgoing]  += weight
            node_info[src][:rank] ||= 1
            node_info[dst] ||= {}
            node_info[dst][:rank] ||= 1
            node_info[dst][:incoming] ||= {}
            node_info[dst][:incoming][src] = weight
        end

        avg_page_rank = 0
        counter = 0
        #first conditon only works when all weights are 1.0 and counter is there to break us out if there is infinite loop.
        while (avg_page_rank*100).to_i < 99 and counter < 100
            node_info.each do |node, info|
                val = 0
                if info[:incoming] && info[:incoming].keys.length > 0
                    info[:incoming].each do |inbound_node, weight|
                        val += node_info[inbound_node][:rank]*weight/total_weight[inbound_node]
                    end
                end
                node_info[node][:rank] = (1-@damping) + @damping*val
            end
            avg_page_rank = node_info.map{|n, info| info[:rank]}.inject(:+)/node_count
            counter += 1
        end
        Hash[*node_info.map{|node, info| [node, info[:rank]]}.flatten]
    end
end

def debug
    edges = [
     ['a', 'b', 1.0],
     ['a', 'c', 1.0],
     ['b', 'c', 1.0],
     ['c', 'a', 1.0],
    ]
    edges = [
        ['a', 'b', 0.5],
        ['a', 'c', 1]
    ]
    ranker = WeightedPageRank.new(edges)
    puts ranker.rank()
end

#debug
