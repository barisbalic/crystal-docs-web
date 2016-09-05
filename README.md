# crystal-docs-web

Code for the [crystal-docs.org](https://crystal-docs.org) website.

Requires crystal 0.18.7+

You will need to create a GitHub developer application in order to test user interaction.

When starting the application you will need to provide the following environment variables:

- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`
- `CRYSTALDOCS_BASE_URL` which is used to generate the `redirect_uri` for the OAuth flow, making it easier to test locally.

Build with `crystal build --release src/crystal-docs-web.cr`.

## Contributing

1. Fork it ( https://github.com/barisbalic/crystal-docs-web/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[barisbalic]](https://github.com/barisbalic) Baris Balic - creator, maintainer
