# jst_myplace
*Resumé, portfolio, and blog*

## Fly.io
deployed at [jst-myplace.fly.dev](https://jst-myplace.fly.dev)

```sh
# deploy current version
flyctl deploy
```


## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Notes

### todos
- [ ] make sure to only render static content once
  - prerender static content on startup or..
  - prerender static content on first request 
  - prerender the parts of dynamic content that are static
- [ ] blog
- [ ] resume
- [ ] portfolio
- [ ] use markdown for content
- [ ] collect stats
- [ ] demonstrate power of the BEAM somehow...
- [ ] show performance stats and system info on page
- [ ] add a contact form
- [ ] write tests where it makes sense

### ideas
- [ ] use llm inference for chatbot
- [ ] set up live chat with me
- [ ] have a "Back Stage" section technically minded people (developers etc.)
- [ ] use filespy to watch for changes and reload the server when running in localy
- [ ] maybe fetch jot/md from a git repo


## used libraries

### jot
parsing tests are based on the ones in [jot](https://hexdocs.pm/jot/)

