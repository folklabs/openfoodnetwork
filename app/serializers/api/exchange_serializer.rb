class Api::ExchangeSerializer < ActiveModel::Serializer
  attributes :id, :sender_id, :receiver_id, :incoming, :pickup_time, :pickup_instructions

  has_many :variants
  has_many :enterprise_fees

  def pickup_time
    ''
  end

  def pickup_instructions
  end

end



#   r.list_of :exchanges, OpenFoodNetwork::Permissions.new(spree_current_user).order_cycle_exchanges(@order_cycle).order('id ASC') do |exchange|
#     r.element :id
#     r.element :sender_id
#     r.element :receiver_id
#     r.element :incoming

#     r.element :variants, Hash[ exchange.variants.map { |v| [v.id, true] } ], {}

#     r.list_of :enterprise_fees do |fee|
#       r.element :id
#       r.element :enterprise_id
#     end

#     r.element :pickup_time
#     r.element :pickup_instructions
#   end
# end
