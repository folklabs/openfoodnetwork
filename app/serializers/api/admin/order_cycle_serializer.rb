include OrderCyclesHelper

class Api::Admin::OrderCycleSerializer < ActiveModel::Serializer
  attributes :id, :name, :orders_open_at, :orders_close_at, :coordinator_id,
             :coordinator_fees, :exchanges, :enterprise_fees


  def orders_open_at
    object.orders_open_at.to_s
  end

  def orders_close_at
    object.orders_close_at.to_s
  end

  has_many :exchanges, serializer: Api::ExchangeSerializer

  def enterprise_fees
    ''
  end

end


