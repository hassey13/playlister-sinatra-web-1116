module Slug
  module InstanceMethods
    def slug
      self.name.gsub(" ","-").downcase
    end
  end
  module ClassMethods
    def find_by_slug(slug)
      not_slug = slug.split("-").map {|word| word.capitalize}.join(" ")
      self.where('lower(name) = ?', not_slug.downcase).first
    end
  end
end
