package = 'nginx-metrix'
version = 'scm-1'
source = {
  url    = "git://github.com/ekho/nginx-metrix.git",
  branch = "master",
  dir    = 'nginx-metrix',
}
description = {
  summary    = 'Extended Nginx status and metrics.',
  detailed   = [[Extended Nginx status and metrics.]],
  homepage   = 'https://github.com/ekho/nginx-metrix/',
  license    = 'MIT <http://opensource.org/licenses/MIT>',
  maintainer = 'Boris Gorbylev <ekho@ekho.name>',
}
dependencies = {
  'lua ~> 5.1',
  'lpeg',
  'dkjson',
  'fun-alloyed',
  'inspect',
  'lust',
}

build = {
  type = "builtin",
  modules = {
    ['nginx-metrix.main']                              = 'nginx-metrix/main.lua',

    ['nginx-metrix.collectors']                        = 'nginx-metrix/collectors.lua',
    ['nginx-metrix.listener']                          = 'nginx-metrix/listener.lua',
    ['nginx-metrix.logger']                            = 'nginx-metrix/logger.lua',
    ['nginx-metrix.scheduler']                         = 'nginx-metrix/scheduler.lua',
    ['nginx-metrix.version']                           = 'nginx-metrix/version.lua',

    ['nginx-metrix.lib.is']                            = 'nginx-metrix/lib/is.lua',

    ['nginx-metrix.collectors.request']                = 'nginx-metrix/collectors/request.lua',
    ['nginx-metrix.collectors.status']                 = 'nginx-metrix/collectors/status.lua',
    ['nginx-metrix.collectors.upstream']               = 'nginx-metrix/collectors/upstream.lua',

    ['nginx-metrix.output.helper']                     = 'nginx-metrix/output/helper.lua',
    ['nginx-metrix.output.renderer']                   = 'nginx-metrix/output/renderer.lua',

    ['nginx-metrix.storage.collector_wrapper_factory'] = 'nginx-metrix/storage/collector_wrapper_factory.lua',
    ['nginx-metrix.storage.dict']                      = 'nginx-metrix/storage/dict.lua',
    ['nginx-metrix.storage.namespaces']                = 'nginx-metrix/storage/namespaces.lua',
    ['nginx-metrix.storage.serializer']                = 'nginx-metrix/storage/serializer.lua',
    ['nginx-metrix.storage.window']                    = 'nginx-metrix/storage/window.lua',
  },
}
