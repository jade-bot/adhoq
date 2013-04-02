program = require 'commander'
{version} = require './package'

program
  .version(version)

program
  .command('new <name>')
  .description('Generate new site in directory <name>')
  .action (name) ->
    console.log 'name',name

program
  .command('*')
  .description('Display site information')
  .action (env) ->
    console.log 'env',env

program.parse process.argv
