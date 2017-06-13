module JsonApiClient
  module Associations
    module HasOne
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one(attr_name, options = {})
         association = HasOne::Association.new(attr_name, self, options)

          self.send :define_method, attr_name do
            get_has_one_relationship(association)
          end

          self.associations += [association]
        end
      end

      def get_has_one_relationship(association)
        relationship_name = association.attr_name
        unless instance_variable_get(:"@#{relationship_name}").nil?
          instance_variable_get(:"@#{relationship_name}")
        else
          relationship_data = relationships.send(relationship_name.to_sym)['data']
          # byebug
          if defined?(last_result_set.included) && (last_result_set.included.data != {}) && last_result_set.included.data_for(relationship_name, relationship_data)
            included_relationship = last_result_set.included.data_for(relationship_name, relationship_data)
          end
          if included_relationship
            instance_variable_set(:"@#{relationship_name}", included_relationship)
          else
            instance_variable_set(:"@#{relationship_name}", association.association_class.find(relationship_data['id']).first)
          end
        end
      end

      class Association < BaseAssociation
        def from_result_set(result_set)
          result_set.first
        end
      end
    end
  end
end