#Module Inclusions:
The class includes three modules: HTTPVerbs, RouteMatcher, and Debug. This suggests that the class leverages methods or constants defined in these modules for handling HTTP verbs, route matching, and debugging functionality, respectively.

#Initialization:
The initialize method sets up the router with empty routes and middlewares arrays and initializes a RequestHandler object, passing self (the router instance) to it.

#Route Matching:
The match method is used to define routes. It takes an HTTP method, a path, and a block (handler).
The path is split into segments and processed to extract parameters and build a regular expression for matching paths.
A new Route object is created and added to the @routes array.

There's a call to debug_output, presumably for logging or debugging purposes.

#Middlewares:
The use method allows adding middleware to the router. Middlewares are stored in the @middlewares array.
Handling Requests:
The call method is the entry point for handling a request.
It creates Request and Response objects.
If there are no middlewares, it directly calls the @request_handler.
If there are middlewares, it processes each middleware in order, and if a response is finished by any middleware, it returns that response.
Finally, it calls the @request_handler with the request and response.
Route Finding:
The find_route method iterates over the routes and returns the first route that matches the request method and path.
Private Methods:
extract_params_keys extracts parameter keys from path segments.
build_path_regex constructs a regex for the path from the segments.