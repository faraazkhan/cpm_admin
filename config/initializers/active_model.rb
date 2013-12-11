module ActiveModel
  module Serializers
    module JSON
      def as_json(opts={}) #ugly hack for activerecord-sqlserver-adapter. Hopefully they will fix this someday
        super opts.merge!({:except => [:__rn, :__rt]})
      end
      
      def serializable_hash(opts = {})
        super opts.merge!({:except => [:__rn, :__rt]})
      end
    end
  end
end

