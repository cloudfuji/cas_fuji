CasFuji
=======
Bushido's Implementation of the CAS server protocol

TODO
====

  * Connect CasFuji to ActiveRecord to persist tickets to the database
  * Allow for the app to be mapped at any sub-path
  * Allow for the views to be overridden from outside

Install
=======
TODO: The install section is incomplete, and needs to be filled out 

CasFuji is designed to be mounted as a rack application, or to run on its own. When integrating it into your own server, it's best to add it as a git submodule so you can easily stay up to date with any changes made to it.

To install it standalone, run:

    git clone https://github.com/sgrove/cas_fuji.git
    bundle install
    bundle exec rake casfuji:db:create
    bundle exec rake casfuji:db:migrate
    shotgun

and visit https://localhost:9393/


Specs/Test
==========
Kick off the spec suite by running:

    bundle exec rspec spec

Making Your Changes
===================

  * Fork the project (Github has really good step-by-step directions)
  * Start a feature/bugfix branch
  * Commit and push until you are happy with your contribution
  * Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.
  * After making your changes, be sure to run the CasFuji RSpec specs to make sure everything works.
  * Submit your change as a Pull Request and update the GitHub issue to let us know it is ready for review.

Authors
=======

  * [Sean Grove](https://github.com/sgrove) (sean@gobushido.com)

Thanks
======

 * The RubyCAS project was hugely inspirational in getting this out the door. We were able to use them stably for months before writing a server in our own style, so huge thanks to them!


License & Copyright
===================
Released under the MIT license. See LICENSE for more details.

All copyright Bushido Inc. 2011

