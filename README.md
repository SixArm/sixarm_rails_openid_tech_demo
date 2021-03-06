# Rails » OpenID » Tech demo for programmers

This Rails OpenID tech demo shows a simple example of authentication using Rails 3, RSpec 2, and the ruby-openid gem.

This tech demo is intended for programmers who want to see source code.


## Step 1

  * To get the code, clone this git repository.
  * Customize the file <code>./app/controllers/openid_controller.rb</code> by setting the variables <code>realm</code> and <code>return_to</code>. The file explains how to do this.

## Step 2

  * Run the app however you like, for example by using the <code>rails server</code> command.
  * Connect to <code>http://example.com/openid/</code> (change the URL for your own site)
  * The app prompts for your OpenID URL, such as <code>http://alice.myopenid.com</code>

## Step 3

  * When you enter your OpenID URL, your browser redirects you to your OpenID server, and asks you to sign in.
  * When you sign in, your OpenID site may show you some confirmation messages and will send you back to your site.
  * The app shows a result message for "Success", "Failure", "Cancel", or "Setup Needed".


## What's next?

If you want to understand more about OpenID source code, we suggest reading the ruby-openid gem's source code because it's well written and has plenty of comments.

If you want to use OpenID in your web application, we suggest learning about OpenID integration with web frameworks and and authentication gems:

  * [Our Ruby OpenID tech demo for the command line](https://github.com/SixArm/sixarm_ruby_openid_tech_demo) - Like this app, yet independent of Rails.
  * [Rack::OpenID] (https://github.com/josh/rack-openid) - Provides a more HTTPish API around the ruby-openid library.
  * [OmniAuth OpenID](https://github.com/intridea/omniauth-openid) - Full authentication system with providers for OpenID, Facebook, Twitter, and many more.
  * [Supporting OpenID In Your Applications](http://danwebb.net/2007/2/27/the-no-shit-guide-to-supporting-openid-in-your-applications) - code for Rails 2.
  * [Minimal OpenID glue for Rails authentication](http://anthonybailey.livejournal.com/35207.html) - code for Rails 2.


## Google OpenID variations

Google provides a unique ID that is independent of the user's name and email address:

http://code.google.com/apis/accounts/docs/OpenID.html

The Google-supplied identifier, which has no connection to the user's actual Google account name or password, is a persistent value; it remains constant even if the user changes their Google user name and/or email address. This identifier is also a "directed identity", that is, Google returns a different value to each relying party. Google uses the request parameter openid.realm to recognize the relying party, so if the third-party application decides to change this value, all user identifiers will change.


## Troubleshooting SessionRestoreError

If you get an error like this:

  * ActionDispatch::Session::SessionRestoreError

Then you need to clear out the session store. This demo uses the in-memory cookie store because it is more secure on multi-app systems, and the easiest way to clear out the session store is to invalidate the existing cookies by changing the app's secret token:

  * Edit <code>config/initializers/secret_token.rb
  * Change the token to anything different.
  * Restart the server.


## Credits

The Ruby OpenID gem is by JanRain, and it has excellent code with comments and examples. This demo is derived from the gem.

This demo is by Joel Parker Henderson, thanks to the University of California, Berkeley and the University of California, Irvine.

Feedback is welcome. Pull requests are welcome too.
