module JsonApiClient
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(attr_name, options = {})
            association = HasMany::Association.new(attr_name, self, options)
           self.send :define_method, attr_name do
            get_has_many_relationship(association)
          end
          self.associations = self.associations + [association]
        end
      end

      def get_has_many_relationship(association)
        unless instance_variable_get(:"@#{association.attr_name}").nil?
          instance_variable_get(:"@#{association.attr_name}")
        else
          relateds = []
          relateds_to_query = []
          relationships.send(association.attr_name.to_sym)['data'].each do |related|
            relationship_id = related['id']
            relationship_type = related['type']
            if defined?(last_result_set.included.data) && last_result_set.included.data[relationship_type]
              included_relationship = last_result_set.included.data[relationship_type][relationship_id]
            end
            if included_relationship
              relateds << included_relationship
            else
              relateds_to_query << relationship_id
            end
          end
          relateds = association.association_class.where(id: relateds_to_query.uniq.join(',')).find if relateds_to_query.size > 0
          instance_variable_set(:"@#{association.attr_name}", relateds)
        end
      end

      class Association < BaseAssociation
      end
    end
  end
end