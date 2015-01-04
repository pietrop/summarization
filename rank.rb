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
        node_info = {}
        total_incoming_weight = {}
        total_weight_sum = 0

        @edges.each do |edge|
            total_incoming_weight[edge[0]] ||= 0
            total_incoming_weight[edge[0]]  += edge[2]
            total_weight_sum += edge[2]
        end

        @edges.each do |edge|
            src = edge[0]
            dst = edge[1]
            weight = edge[2]*1.0
            node_info[src] ||= {}
            node_info[src][:rank] ||= 1
            node_info[dst] ||= {}
            node_info[dst][:rank] ||= 1
            node_info[dst][:incoming] ||= {}
            node_info[dst][:incoming][src] = weight
        end

        counter   = 100   #get out of infinite loop in odd cases.  
        err       = 1.0   #track change in err % to total_weight
        precision = 10000 
        while (err*precision).to_i > 0 and counter > 0
            err = 0.0
            node_info.each do |node, info|
                val = 0
                if info[:incoming] && info[:incoming].keys.length > 0
                    info[:incoming].each do |inbound_node, weight|
                        val += node_info[inbound_node][:rank]*weight/total_incoming_weight[inbound_node]
                    end
                end
                prev_rank = node_info[node][:rank]
                node_info[node][:rank] = (1-@damping) + @damping*val
                err += (node_info[node][:rank] - prev_rank).abs
            end
            err /= total_weight_sum
            counter -= 1
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
    #puts ranker.rank()
end

#debug
