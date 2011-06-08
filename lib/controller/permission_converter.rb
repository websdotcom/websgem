# only needed until all apps have upgraded and converted to new permissions ( videos, blogs, forums )

module Webs
  module Permission
    DISABLED = -1
    ANYONE = 0
    LIMITED = 1
    MEMBERS = 2
    MODERATORS = 3
    OWNER = 4
    ADMIN = 5
    
    # mappings to http://wiki.beta.freewebs.com/index.php/Fw:member-level-select
    def webs_member_level_to_int member_level
      {
        'anyone'=>Webs::Permission::ANYONE,
        'limited'=>Webs::Permission::LIMITED,
        'member'=>Webs::Permission::MEMBERS,
        'moderator'=>Webs::Permission::MODERATORS,
        'admin'=>Webs::Permission::ADMIN
      }[member_level.downcase]
    end      

    # mappings of the select value of fw:member-level-select to the old int vals
    # TODO: convert data to new vals, don't have time right now
    def webs_member_level_value_to_old_member_level webs_member_level
      {
        '-255'=>Webs::Permission::ANYONE,
        '25'=>Webs::Permission::LIMITED,
        '50'=>Webs::Permission::MEMBERS,
        '75'=>Webs::Permission::MODERATORS,
        '100'=>Webs::Permission::ADMIN,
        '125'=>Webs::Permission::OWNER,
        '255'=>Webs::Permission::DISABLED
      }[webs_member_level]
    end

    def webs_int_to_member_level n
      {
        Webs::Permission::DISABLED=>'disabled',
        Webs::Permission::ANYONE=>'anyone',
        Webs::Permission::LIMITED=>'limited',
        Webs::Permission::MEMBERS=>'member',
        Webs::Permission::MODERATORS=>'moderator',
        Webs::Permission::ADMIN=>'admin',
        Webs::Permission::OWNER=>'admin'
      }[n]
    end      

    # converts level which is an int for the select options of a fw:member-level-select
    # first to an associated Webs::Permission then to a blog member level
    # TODO: This should be cleaned up and blogs should use the fw:member-level-select values
    # the mapping is useful if you need to change the result, generally sending returning admin if owner
    # since most of the apps use owner not admin
    # The generally needs to be done in params since some objects contain validations
    # example: 
    #  convert_webs_member_level( params[:entries], :view_level, {Webs::Permission::ADMIN=>Webs::Permission::OWNER} )
    #  will take a webs member-level-select and convert it to a  Webs::Permission mapping ADMIN to OWNER
    def convert_webs_member_level h, key, mapping={}
      return if h.nil?
      v = webs_member_level_value_to_old_member_level( h[key] )
      h[key] = mapping[v] || v
    end
  end
end
