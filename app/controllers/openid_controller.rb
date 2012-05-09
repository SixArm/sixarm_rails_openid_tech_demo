require 'openid'

class OpenidController < ApplicationController

  include OpenidHelper

  # Show a form requesting the user's OpenID
  def index
  end

  # Begin the OpenID verification process
  def begin
    openid_url = params[:openid_url]

    if openid_url.blank?
      flash[:error] = "To use this, please type in the box."
      redirect_to openid_root_path and return
    end

    # We begin using the consumer with the user's OpenID URL.
    #
    # This returns a CheckID Request object containing the discovered
    # information, with a method for building a redirect URL to the
    # server, as described later.
    #
    # The CheckID Request object may also be used to add extension
    # arguments to the request, using its add_extension_arg method.
    #
    # If no OpenID server is found, this raises a DiscoveryFailure.

    begin
      logger.info "openid_url:#{openid_url} ..."
      checkid_request = openid_consumer.begin openid_url
      logger.info "openid_url:#{openid_url} success"
    rescue OpenID::DiscoveryFailure
      logger.info "openid_url:#{openid_url} failure"
      flash[:error] = "Couldn't find an OpenID for that URL"
      redirect_to openid_root_path and return
    end

    # <tt>realm</tt> is the URL (or URL pattern) that identifies
    # your web site to the user when he or she is authorizing it.
    # The realm is typically the homepage URL of your site.
    #
    # In older versions of OpenID, the realm is called "trust root".

    realm = root_url  # e.g. "http://example.com"

    # <tt>return_to</tt> is the URL that the OpenID server will send
    # the user back to after attempting to verify his or her identity.

    return_to = openid_complete_url  # e.g. "http://example.com/openid/complete" 

    # Next, you call the redirect_url method on the CheckIDRequest object.
    #
    # Returns a URL with an encoded OpenID request. The URL is the OpenID
    # provider's endpoint URL with parameters appended as query arguments.
    # You should redirect the user agent to this URL.
    #
    # OpenID 2.0 endpoints can also accept POST requests.

    url = checkid_request.redirect_url(realm, return_to)

    # We then redirect the user to the resulting URL where the user logs
    # in to their OpenID server, authorises your verification request and
    # is (normally) redirected to return URL you provided.
    #
    # When the user is redirected back to your application, the server
    # will append information about the response in the query string,
    # which the OpenID library will unpack.
    #
    # These next steps are done in the other program in this directory.

    redirect_to url and return

  end

  # Complete the OpenID verification process
  def complete
    logger.info "params:#{params.inspect} request.url:#{request.url}"
    response = openid_consumer.complete(params_for_openid(params), request.url)
    logger.info "response:#{response.inspect}"

    # Handle the response.
    #
    # A typical Rails web application would set up the <code>session</code>,
    # make the <code>current_user</code> return the user's ActiveRecord object,
    # and redirect the user's browser to the start page of the web application.

    case response.status
    when OpenID::Consumer::SUCCESS
      logger.info "SUCCESS response.identity_url:#{response.identity_url}"
      @identity_url = response.identity_url
      session[:openid] = response.identity_url
      flash[:notice] = "Success. You are signed in: #{@identity_url}"
      redirect_to root_path and return
    when OpenID::Consumer::FAILURE
      logger.info "FAILURE endpoint:#{response.endpoint||'?'} message:#{response.message||'?'} contact:#{response.contact||'?'}"
      flash[:error] = "Failure. You are not signed in. #{response.message||'?'}"
      redirect_to openid_root_path and return
    when OpenID::Consumer::CANCEL
      logger.info "CANCEL request.url:#{request.url}"
      flash[:notice] = "Cancelled. You are not signed in."
      redirect_to openid_root_path and return
    when OpenID::Consumer::SETUP_NEEDED
      logger.info "SETUP_NEEDED request.url:#{request.url}"
      flash[:error] = "Setup Needed. This is not yet supported"
      redirect_to openid_root_path and return
    else
      raise "Response not recognized: response.class:#{response.class}"
    end

  end

  protected

  # Create a consumer singleton with in-memory store, and memoize it.
  # Return the consumer.

  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session, nil)
  end


  # <tt>google openid url</tt> is how google looks up accounts.
  # The user must be signed in to Google (e.g. Gmail) already.
  # The URL is atypical in that the user's info is not included.
  # We're not using it yet; it's here to help future devs.

  GOOGLE_OPENID_URL = "https://www.google.com/accounts/o8/id"

end
