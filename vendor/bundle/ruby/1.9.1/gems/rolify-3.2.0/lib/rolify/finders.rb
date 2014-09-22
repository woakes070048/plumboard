module Rolify
  module Finders
    def with_role(role_name, resource = nil)
      self.adapter.scope(self, :name => role_name, :resource => resource)
    end

    def with_all_roles(*args)
      users = []
      args.each do |arg|
        if arg.is_a? Hash
          users_to_add = self.with_role(arg[:name], arg[:resource])
        elsif arg.is_a?(String) || arg.is_a?(Symbol)
          users_to_add = self.with_role(arg)
        else
          raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
        end
        users = users_to_add if users.empty?
        users &= users_to_add
        return [] if users.empty?
      end
      users
    end

    def with_any_role(*args)
      users = []
      args.each do |arg|
        if arg.is_a? Hash
          users_to_add = self.with_role(arg[:name], arg[:resource])
        elsif arg.is_a?(String) || arg.is_a?(Symbol)
          users_to_add = self.with_role(arg)
        else
          raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
        end
        users += users_to_add
      end
      users.uniq
    end
  end
end