program = require 'commander'
{version} = require './package'

program
  .version("AdHoq #{version}")

program
  .command('new <name>')
  .description('Generate new site in directory <name>')
  .action (name) ->
    console.log 'name',name

program
  .command('watch')
  .description('Launch the site in live preview mode')
  .action (env) ->
    console.log 'env',env

program
  .command('test')
  .description('Run all tests on this site')
  .action (env) ->
    console.log 'env',env

program
  .command('gen')
  .description('Generate the static site')
  .action (env) ->
    console.log 'env',env

program
  .command('info')
  .description('Display site information')
  .action (env) ->
    console.log 'env',env

program.parse process.argv
