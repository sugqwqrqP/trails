Rails.application.config.generators do |g|
  g.helper false        # ヘルパーを生成しない                                                                                                                                                                     
  g.skip_routes true    # config/routes.rbを変更しない                                                                                                                                                         
end
