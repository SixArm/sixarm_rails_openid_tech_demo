module OpenidHelper

  # We use params.reject instead of params.accept because we want to
  # preserve the params class, e.g. Rails uses HashWithIndifferentAccess.

  def params_for_openid(params)
    params.reject{|k,v| k !~ /^openid\./ }
  end

end
