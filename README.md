# Linger

Linger takes advantage of the [new](https://github.com/stimulusreflex/stimulus_reflex/pull/588) `throw :forbidden` feature in StimulusReflex 3.5 to provide _unopinionated_ authentication security to Reflexes. If you have two tabs open and sign out in one, you should not be able to run Reflexes in the other tab. If you have sessions active on multiple devices, signing out on one should not impact the sessions on the others. These deceptively hard requirements are addressed by creating a composite key in Redis for every uniquely identified session.

Developers can respond to authentication failures by handling Reflexes that arrive in a new `forbidden` state. Forbidden Reflexes are functionally identical to halted Reflexes (eg. `throw :abort`) except that they (conceptually and semantically) represent Reflexes which were not allowed to execute.

You are **strongly advised** to consult the [Lingering Presence](https://github.com/leastbad/lingering_presence) reference application for further details, especially in advance of full documentation.

## Requirements and setup

- StimulusReflex 3.5
- Redis server 4.0 and Redis Ruby client 4.2

Add the `linger` gem to your `Gemfile`.

Linger makes use of the same shared Redis config that Kredis uses. Just make sure that you have a valid `config/redis/shared.yml` and you're all set. You can learn more on the [Kredis](https://github.com/rails/kredis#setting-ssl-options-on-redis-connections) page.

## Usage

In your Reflex class, create a `before_reflex` callback:

```ruby
before_reflex :authenticate_connection!
```

We recommend placing this in the `app/reflexes/application_reflex.rb` class, but you can manually add it to your Reflex classes on an ad-hoc basis.

```ruby
class ApplicationReflex < StimulusReflex::Reflex
  before_reflex :authenticate_connection!
end
```

You are then responsible for calling `Linger` methods to allow and deny user contexts across all possible cases. You pass in whatever variables are expected, based on your `identified_by` Set that is defined in your `app/channels/application_channel/channel.rb`. The order you provide the identifiers is not important:

```ruby
# after sign in
Linger.allow session, current_user
Linger.deny session
# after sign out
Linger.allow session
Linger.deny session, current_user
```

Finally, the developer can either terminate Action Cable connections or create a handler for the `reflexForbidden` life-cycle state. You can see that a starting point for customization is presented in `app/javascript/controllers/application_controller.js` where you can see a sample handler for forbidden Reflexes is described. Instead of refreshing the page, you could use a notification library to pop up a toast message, for example.

## Credit and acknowledgements

The structure of this project borrows both layout and code extensively from [Kredis](https://github.com/rails/kredis). Thanks to all of the Kredis contributors for such an excellent tool.
