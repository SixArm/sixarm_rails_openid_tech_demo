require 'openid'

class OpenidController < ApplicationController

  # Show a form requesting the user's OpenID
  def index
  end

  # Begin the OpenID verification process
  def begin
    openid_url = params[:openid_url]

    if openid_url.blank?
      flash[:error] = "To use this, please type in the box."
      redirect_to '/openid'
      return
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
      checkid_request = openid_consumer_begin openid_url
      Rails.logger.info "OpenidController#begin openid_url:#{openid_url} success"
    rescue OpenID::DiscoveryFailure
      Rails.logger.info "OpenidController#begin openid_url:#{openid_url} failure"
      flash[:error] = "Couldn't find an OpenID for that URL"
      redirect_to '/openid'
      return
    end

    # <tt>realm</tt> is the URL (or URL pattern) that identifies
    # your web site to the user when he or she is authorizing it.
    # The realm is typically the homepage URL of your site.
    #
    # In older versions of OpenID, the realm is called "trust root".

    realm = root_url  # e.g. "http://example.com"

    # <tt>return_to</tt> is the URL that the OpenID server will send
    # the user back to after attempting to verify his or her identity.

    return_to = "#{root_url}openid/complete"

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

    redirect_to url

  end

  # Complete the OpenID verification process
  def complete
    Rails.logger.info "OpenidController#complete params:#{params.inspect} request.url:#{request.url}"
    response = openid_consumer.complete(params, request.url)
    Rails.logger.info "OpenidController#complete response.status:#{response.status}"

    # Handle the response.
    #
    # A typical Rails web application would set up the <code>session</code>,
    # make the <code>current_user</code> return the user's ActiveRecord object,
    # and redirect the user's browser to the start page of the web application.

    case response.status
    when OpenID::Consumer::SUCCESS
      Rails.logger.info "OpenidController#complete success"
      session[:openid] = response.identity_url
      flash[:notice] = "Success. You are signed in."
      redirect_to root_path
    when OpenID::Consumer::FAILURE
      Rails.logger.info "OpenidController#complete failure"
      flash[:error] = "Failure: endpoint: #{response.endpoint||'?'} message: #{response.message} contact: #{response.contact}"
      redirect_to '/openid'
    when OpenID::Consumer::CANCEL
      Rails.logger.info "OpenidController#complete cancel"
      flash[:notice] = "Cancelled. You are not signed in."
      redirect_to '/openid'
    when OpenID::Consumer::SETUP_NEEDED
      Rails.logger.info "OpenidController#complete setup needed"
      flash[:error] = "Setup Needed. This is not yet supported"
      redirect_to '/openid'
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

  def openid_consumer_begin(openid_url)
    Rails.logger.info "OpenidController#begin openid_url:#{openid_url}"
    openid_consumer.begin openid_url
  end

  # <tt>google openid url</tt> is how google looks up accounts.
  # The user must be signed in to Google (e.g. Gmail) already.
  # The URL is atypical in that the user's info is not included.
  # We're not using it yet; it's here to help future devs.

  GOOGLE_OPENID_URL = "https://www.google.com/accounts/o8/id"

end
