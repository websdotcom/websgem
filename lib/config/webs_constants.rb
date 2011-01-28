module Webs
  module PermissionLevel
    LEVEL = {
      :anyone => { :name=>'Anyone', :value=>-255 },
      :none => { :name=>'None', :value=>0 },
      :requesting => { :name=>'Requesting Members', :value=>10 },
      :limited => { :name=>'Limited Members', :value=>25 },
      :member => { :name=>'Members', :value=>50 },
      :moderator => { :name=>'Moderators', :value=>75 },
      :admin => { :name=>'Administrators', :value=>100 },
      :owner => { :name=>'Only Me (Site Owner)', :value=>125 },
      :disabled => { :name=>'Disabled', :value=>255 }
    }
    
    LEVELS=LEVEL.keys
    VALUES=LEVEL.values.collect{ |v| v[:value] }.sort
    
    PERMISSION_LEVELS_BY_VALUE=LEVELS.inject({}) do |level_hash, level_key|
      lvl = LEVEL[level_key]
      level_hash[lvl[:value]] = lvl
      level_hash
    end
    
    def self.[](k)
      value_for_level k
    end
    
    def self.level_for_value v
      PERMISSION_LEVELS_BY_VALUE[v]
    end
    
    def self.value_for_level k
      LEVEL[k][:value]
    end
    
    def self.options_for_select options={}
      levels = LEVELS
      names = options.delete(:names)
      names ||= {}
      only = options.delete(:only)
      levels = only if only
      except = options.delete(:except)
      levels = levels-except if except
      levels.collect { |lvl_key| [ names[lvl_key] || LEVEL[lvl_key][:name], LEVEL[lvl_key][:value] ] }
    end
    
    def self.compare(k1, k2)
      value_for_level( k1 ) - value_for_level( k2 )
    end
    
    # ex: Webs::PermissionLevel.is_at_least( 25, :limited ) => true
    def self.is_at_least( v, k )
      value_for_level( k ) >= v
    end
  end

  module CommentsOrder
    DESC  = 0
    ASC   = 1
    VIEWS = [[DESC, "Newest first (default)"], [ASC, "Oldest first"]]
    SELECT_OPTIONS = VIEWS.map { |val, disp| [disp, val] }
    VAL_LIST  = VIEWS.map {|val, disp| val}
    def self.val_to_str(val)
      val.to_i == ASC ? "ASC": "DESC"
    end
  end
end