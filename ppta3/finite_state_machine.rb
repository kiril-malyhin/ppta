require_relative 'graph_drawer'

class FSM
  extend Forwardable
  # Q - states set
  # T - input symbols set
  # F - transition func QxT
  # H - initial states set
  # Z - finish states set

  def_delegators :@graph_drawer, :output
  attr_accessor :rules, :Q, :T, :F, :H, :Z, :partition, :group_states_map

  def initialize(fsm_definitions, state_transition_file)
    @state_transition_file = state_transition_file

    @F = Hash.new { |hash, key| hash[key] = Hash.new }
    @H = fsm_definitions["H"]
    @Z = fsm_definitions["Z"]

    state_transition_function_from_csv

    @graph_drawer = GraphDrawer.new(self)
  end

  def minimize
    eliminate_unreachable_states
    merge_equivalent_states
  end

  def console
    puts "Q: #{@Q}"
    puts "T: #{@T}"
    puts "F: #{@F}"
    puts "H: #{@H}"
    puts "Z: #{@Z}"
  end

  private

  def eliminate_unreachable_states
    @reachable_states = [@H]
    traverse_states(@H)
    unreachable = @Q - @reachable_states
    @Q = @Q & @reachable_states
    @Z = @Z & @reachable_states
    unreachable.each { |state| @F.delete(state) }
  end

  def merge_equivalent_states
    @partition = final_partition
    groups_states_map
    replace_equiv_states_in_sets
  end

  def replace_equiv_states_in_sets
    equiv_states = @group_states_map.keys.flatten

    @Q -= equiv_states
    @Z.map! do |state|
      equiv_states.include?(state) ? nonterm_for_group(state) : state
    end.uniq!

    @F.keys.each do |nonterm|
      @F[nonterm].keys.each do |term|
        @F[nonterm][term] = nonterm_for_group(@F[nonterm][term]) if equiv_states.include? @F[nonterm][term]
      end
      if equiv_states.include? nonterm
        new_nonterm = nonterm_for_group(nonterm)
        @F[new_nonterm].empty? ? @F[new_nonterm] = @F.delete(nonterm) : @F.delete(nonterm)
      end
    end
  end

  def final_partition
    _R = []
    _R[0] = []
    _R[0].push(@Z)
    _R[0].push((@Q - @Z))
    n = 1
    _R[n] = []

    while true do
      partition_matrix = buid_partition_matrix(_R[n-1])
      _R[n] = build_new_partition(partition_matrix)

      break if _R[n-1] == _R[n]

      n += 1
    end
    _R[n]
  end

  def groups_states_map
    @group_states_map = {}
    @partition.each do |group|
      if group.length > 1
        @group_states_map[group] = generate_nonterm_in(@Q)
      end
    end
    @group_states_map
  end

  def nonterm_for_group(nonterm)
    group  = @group_states_map.keys.find { |group| group.include? nonterm }
    !group.nil? ? @group_states_map[group] : nil
  end

  def equivalence_class(partition, state)
    partition.find_index { |set| set.include? state }
  end

  def buid_partition_matrix(partition)
    partition_matrix = Hash.new { |hash, key| hash[key] = Hash.new }
    @F.keys.each do |nonterm|
      partition_matrix[nonterm]
      @F[nonterm].keys.each do |term|
        partition_matrix[nonterm][term] = equivalence_class(partition, @F[nonterm][term])
      end
    end
    partition_matrix
  end

  def build_new_partition(partition_matrix)
    grouped = partition_matrix.keys.group_by{ |nonterm| partition_matrix[nonterm] }
    grouped.values
  end

  def traverse_states(state)
    @F[state].each do |term, new_state|
      unless @reachable_states.include? new_state
        @reachable_states.push(new_state)
        traverse_states(new_state)
      end
    end
  end

  def state_transition_function_from_csv
    state_transition = CSV.read('state_transition_function.csv',
                                headers:true, col_sep: ' ', skip_blanks: true)

    @Q = Marshal.load(Marshal.dump(state_transition.headers))[1..-1]
    @T = Marshal.load(Marshal.dump(state_transition['F']))

    @Q.each do |nonterm|
      @T.each_with_index do |term, i|
        value =state_transition[nonterm][i]
        unless value == 'ø'
          @F[nonterm][term] = value
        end
      end
    end
  end

  def generate_nonterm(set)
    (('A'..'Z').to_a - set)[0]
  end

  def generate_nonterm_in(set)
    nonterm = generate_nonterm(set)
    set << nonterm
    nonterm
  end

end