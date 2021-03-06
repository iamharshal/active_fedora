module ActiveFedora
  # a Hash of properties that have changed and their present values
  class ChangeSet

    attr_reader :object, :graph, :changed_attributes

    # @param [ActiveFedora::Base] object The resource that has associations and properties
    # @param [RDF::Graph] graph The RDF graph that holds the current state
    # @param [Array] changed_attributes A list of properties that have changed
    def initialize(object, graph, changed_attributes)
      @object = object
      @graph = graph
      @changed_attributes = changed_attributes
    end

    def empty?
      changes.empty?
    end

    def changes
      @changes ||= changed_attributes.each_with_object({}) do |key, result|
        if m = /^.*_ids?$/.match(key)
          predicate = object.association(m[0].to_sym).reflection.predicate
          result[predicate] = graph.query(predicate: predicate)
        elsif object.class.properties.keys.include?(key)
          predicate = graph.reflections.reflect_on_property(key).predicate
          result[predicate] = graph.query(predicate: predicate)
        elsif object.local_attributes.include?(key)
          raise "Unable to find a graph predicate corresponding to the attribute: \"#{key}\""
        end
      end
    end
  end
end
