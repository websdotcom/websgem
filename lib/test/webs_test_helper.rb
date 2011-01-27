module Webs
  module WebsTestHelper
    def fw_test_params options={}
      { :fw_sig_site=>rand(100000),
        :fw_sig_is_admin=>'0',
        :fw_sig_permission_level=>Webs::PermissionLevel[:anyone],
        :fw_sig_tier=>'0',
        :fw_sig_url=>'localhost:3000',
        :fw_sig_user=>rand(100000),
        :fw_sig_social=>'1', 
        :fw_sig_premium=>'0',
        :fw_sig_width=>800 }.merge( options )
    end
    
    def fw_sitebuilder_test_params options={}
      fw_test_params options.merge( :fw_sig_is_admin=>'1' )
    end
    
    # Permute: is_admin, permission_level, tier, social & premium
    def fw_param_permuter options={}, &block
      param_vals = {
        :fw_sig_is_admin=>[0,1],
        :fw_sig_permission_level=>Webs::PermissionLevel::VALUES,
        :fw_sig_social=>[0,1],
        :fw_sig_premium=>[0,1],
        :fw_sig_tier=>[0,1,2,3]
      }
      params = fw_test_params( options ) 
      permute_params params, param_vals, block
    end
    
    def permute_params params, h_vals, block
      if h_vals.size == 0
        block.call( params )
      else
        k = h_vals.keys.first
        vals = h_vals.delete(k)
        vals.each do |v|
          params[k] = v.to_s
          permute_params params, h_vals.clone, block
        end
      end
    end
    
    def assert_difference(executable, how_many = 1, &block)
      before = eval(executable)
      yield
      after = eval(executable)
      after.should == before + how_many
    end
    
    def assert_no_difference(executable, &block)
      before = eval(executable)
      yield
      after = eval(executable)
      after.should == before
    end    
  end
end