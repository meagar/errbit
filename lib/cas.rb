module Cas

  def self.included(base)
    base.extend ClassMethods

    base.class_eval do
      devise :omniauthable
      def password_required?
        false
      end
    end
  end

  module ClassMethods
    def find_for_cas_oauth(access_token, signed_in_resource=nil)
      access_token = fixup_hash(access_token)
      data = access_token['user_info']
      User.where(:email => data["email"]).first
    end 

    def fixup_hash(hash)
      attribute_map = {
        'name' => 'cn', 
        'first_name' => 'givenName',
        'last_name' => 'sn',
        'email' => 'mail',
        'phone' => 'telephoneNumber',
        'nickname' => 'sAMAccountName',
        'title' => 'title',
        'location' => 'physicalDeliveryOfficeName',
        'description' => 'description'
      }

      extra = hash.delete('extra').inject({}) { |h,(a,v)| h[a] = YAML.load(v) rescue v; h }
      hash['uid'] = extra['dn'].first if extra['dn']
      hash['user_info'] = attribute_map.inject({}) { |h,(a,ad)| h[a] = extra[ad].first if extra[ad]; h }
      hash['extra'] = extra

      hash
    end
  end

end
