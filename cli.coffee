program = require 'commander'
{version} = require './package'

program
  .version("AdHoq #{version}")
  .usage('<command> [options]')

program
  .command('new <name>')
  .description('Generate new site in directory <name>')

program
  .command('run [port]')
  .description('Run the site in live preview mode')
  .action (env) ->
    require('./cli-run') program.args...

program
  .command('test')
  .description('Run all tests on this site')

program
  .command('build')
  .description('Build a static version of the site')

program
  .command('info')
  .description('Display site information')

program.parse process.argv

unless process.argv[2]
  process.stdout.write program.helpInformation()
  program.emit '--help'
