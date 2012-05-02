module OpenidHelper

  def params_for_openid(params)
    params.select{|k,v| k=~/^openid\./}
  end

end
