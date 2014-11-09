class Api::Admin::EnterpriseFeesSerializer < ActiveModel::Serializer
  attributes :id, :name, :enterprise_id, :enterprise_name, :fee_type, :calculator_type,
             :calculator_description, :calculator_settings

  def name
    @enterprise_fee.enterprise.andand.name
  end

  def calculator_description
    @enterprise_fee.calculator.andand.description
  end

  def calculator_settings
    result = nil

    @controller.send(:with_format, :html) do
      result = @controller.render_to_string :partial => 'admin/enterprise_fees/calculator_settings', :locals => {:enterprise_fee => @enterprise_fee, :index => @index}
    end

    result.gsub('[0]', '[{{ $index }}]').gsub('_0_', '_{{ $index }}_')
  end

end
