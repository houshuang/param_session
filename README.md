ParamSession
=======

This plug came out of my work on using Elixir/Phoenix to serve LTI components, which mostly live in iframes. Several browsers limit, or completely disallow setting cookies from iframes, which means that all the built-in session-persistance mechanisms fail. 

The plug uses the existing mechanisms for encrypting and signing session parameters, but pass these either as a URL parameter, or as a hidden form field. This means that the plug cannot be a plug-and-play replacement. On incoming requests, it parses form or URL parameters, and updates the session_plug field in Conn, allowing put_session, get_session, and delete_session to work seamlessly.

However, to persist the session across requests, one of the provided helpers must be used:

- redirect(conn, url) redirects to a new URL, attaching the session parameter
- gen_url(conn, url) returns a URL with the session parameters (for use in links, etc)
- form_session(conn) returns a string which should be included in an HTML form, which provides
  the hidden field setting (remember to use raw in Phoenix)

You can also directly access the functions that encode and decode sessions,
- gen_cookie(conn) reads the session from conn, and generates a single text string which is encrypted and signed
- string_to_session(conn, string) takes a single string and returns the map of the session variables

The plug requires a config setting. You can copy the example in config/config.exs, changing the secret keys. These should be kept secret, and for production, included in something like prod.secret.exs, which is not stored in a public git repository.

I am not entirely happy with how I am calling the Plug.Session.COOKIE module, but given that it uses a number of private functions, I could not see another way that didn't include copying a bunch of code. 

This library is currently used in production with an EdX course serving thousands of students, and has worked reliably across many browsers. 

It is probably prudent to limit the size of the session, because browsers might have limitations in the length of URLs/parameters that are passed on. If many parameters are required, these could be stored in an ETS table/database, with the paramsession just containing the key. (Future work could bake this into the plug).

Comments/pull requests around style/idiomatic code, better tests, etc., are all welcome.
