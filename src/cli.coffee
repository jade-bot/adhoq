program = require 'commander'
{version} = require '../package'

program
  .version("AdHoq #{version}")
  .usage('<command> [options]')

program
  .command('new <name>')
  .description('Generate new site in directory <name>')
  .action (env) ->
    console.warn 'not yet'
    
program
  .command('run [port]')
  .description('Run the site in live preview mode [3333]')
  .action (env) ->
    require('./cli-run') program.args...

program
  .command('test')
  .description('Run all tests on this site')
  .action (env) ->
    console.warn 'not yet'

program
  .command('build [dir]')
  .description('Build a static version of the site [out]')
  .action (env) ->
    require('./cli-build') program.args...

program
  .command('info')
  .description('Display site information')
  .action (env) ->
    console.warn 'not yet'

program.parse process.argv

unless process.argv[2]
  process.stdout.write program.helpInformation()
  program.emit '--help'
