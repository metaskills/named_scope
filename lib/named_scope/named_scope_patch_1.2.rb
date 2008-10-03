
ActiveRecord::Associations::AssociationProxy.class_eval do
  protected
  def with_scope(*args, &block)
    @reflection.klass.send :with_scope, *args, &block
  end
end

class ActiveRecord::Base
  class << self
    private
    def attribute_condition_with_named_scope(argument)
      case argument
        when ActiveRecord::Associations::AssociationCollection, ActiveRecord::NamedScope::Scope then "IN (?)"
        else attribute_condition_without_named_scope(argument)
      end
    end
    alias_method_chain :attribute_condition, :named_scope
  end
end

ActiveRecord::Associations::HasManyAssociation.class_eval do
  protected
  def method_missing(method, *args, &block)
    if @target.respond_to?(method) || (!@reflection.klass.respond_to?(method) && Class.respond_to?(method))
      super
    elsif @reflection.klass.scopes.include?(method)
      @reflection.klass.scopes[method].call(self, *args)
    else
      create_scoping = {}
      set_belongs_to_association_for(create_scoping)

      @reflection.klass.with_scope(
        :create => create_scoping,
        :find => {
          :conditions => @finder_sql, 
          :joins      => @join_sql, 
          :readonly   => false
        }
      ) do
        @reflection.klass.send(method, *args, &block)
      end
    end
  end
end

ActiveRecord::Associations::HasManyThroughAssociation.class_eval do
  protected
  def method_missing(method, *args, &block)
    if @target.respond_to?(method) || (!@reflection.klass.respond_to?(method) && Class.respond_to?(method))
      super
    elsif @reflection.klass.scopes.include?(method)
      @reflection.klass.scopes[method].call(self, *args)
    else
      @reflection.klass.with_scope(construct_scope) { @reflection.klass.send(method, *args, &block) }
    end
  end
end

ActiveRecord::Associations::HasAndBelongsToManyAssociation.class_eval do
  protected
  def method_missing(method, *args, &block)
    if @target.respond_to?(method) || (!@reflection.klass.respond_to?(method) && Class.respond_to?(method))
      super
    elsif @reflection.klass.scopes.include?(method)
      @reflection.klass.scopes[method].call(self, *args)
    else
      @reflection.klass.with_scope(:find => { :conditions => @finder_sql, :joins => @join_sql, :readonly => false }) do
        @reflection.klass.send(method, *args, &block)
      end
    end
  end
end

