class ActiveRecord::Base
  class << self

    def parse_factory_arguments(args)
      factory_name = (args.first.is_a?(Symbol) ? args.shift : self.name.underscore).to_sym
      properties = args.first || {}
      [factory_name, properties]
    end

    def first_or_gen(attributes = {})
      where(attributes).first || gen(attributes)
    end

    def gen(*args)
      FactoryGirl.create(*parse_factory_arguments(args))
    end

    def prepare(*args)
      FactoryGirl.build(*parse_factory_arguments(args))
    end

    def pick
      records = count
      (records > 0) ? limit(1).offset(rand(records)).first : nil
    end

    def pick_or_gen
      pick || gen
    end

    def prepare_hash(*args)
      FactoryGirl.attributes_for(*parse_factory_arguments(args))
    end

  end
end
