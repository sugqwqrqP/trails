class RunsController < ApplicationController
  DISPLAY_LIMIT = 5

  def index
    result = RunSearchService.call(
      params: params,
      display_limit: DISPLAY_LIMIT,
      include_availability: true,
      enable_pager: true
    )

    @results = result[:results]
    @errors = result[:errors]
    @has_prev = result[:has_prev]
    @has_next = result[:has_next]
    @prev_offset = result[:prev_offset]
    @next_offset = result[:next_offset]
  end
end
