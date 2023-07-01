# frozen_string_literal: true

module RouteMatcher
  def matching_segments?(route_segments, path_segments)
    route_segments.length == path_segments.length
  end

  def matching_route?(route_segments, path_segments)
    route_segments.zip(path_segments).all? do |route_seg, path_seg|
      route_seg == '*' || route_seg.start_with?(':') || route_seg == path_seg
    end
  end

  def extract_params(_route, route_segments, path_segments)
    params = {}

    route_segments.zip(path_segments).each_with_index do |(route_seg, path_seg), i|
      if route_seg.start_with?(':')
        param_key = route_seg[1..]
        params[param_key] = path_seg
      elsif route_seg == '*'
        param_key = route.params_keys[i]
        params[param_key] = path_segments[i..].join('/') if param_key
      end
    end

    params
  end
end
